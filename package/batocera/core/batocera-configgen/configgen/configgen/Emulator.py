import sys
import os
import batoceraFiles
from settings.unixSettings import UnixSettings
import xml.etree.ElementTree as ET
import shlex
from utils.logger import eslog
import yaml
import collections

class Emulator():

    def __init__(self, name):
        self.name = name

        # read the configuration from the system name
        self.config = Emulator.get_system_config(self.name, "/recalbox/system/configgen/configgen-defaults.yml", "/recalbox/system/configgen/configgen-defaults-arch.yml")
        if "emulator" not in self.config or self.config["emulator"] == "":
            eslog.log("no emulator defined. exiting.")
            raise Exception("No emulator found")

        # load configuration from batocera.conf
        recalSettings = UnixSettings(batoceraFiles.batoceraConf)
        globalSettings = recalSettings.loadAll('global')
        systemSettings = recalSettings.loadAll(self.name)

        # update config
        Emulator.updateConfiguration(self.config, globalSettings)
        Emulator.updateConfiguration(self.config, systemSettings)
        self.updateDrawFPS()

        # update renderconfig
        self.renderconfig = Emulator.get_generic_config(self.name, "/usr/share/batocera/shaders/configs/rendering-defaults.yml", "/usr/share/batocera/shaders/configs/rendering-defaults-arch.yml")
        if "shaderset" in self.config and self.config["shaderset"] != "none":
            eslog.log("shaderset={}".format(self.config["shaderset"]))
            globalSettings = recalSettings.loadAll('global-renderer-' + self.config["shaderset"])
            systemSettings = recalSettings.loadAll(self.name + "-renderer-" + self.config["shaderset"])
            self.renderconfig = Emulator.get_generic_config(self.name, "/usr/share/batocera/shaders/configs/" + self.config["shaderset"] + "/rendering-defaults.yml", "/usr/share/batocera/shaders/configs/" + self.config["shaderset"] + "/rendering-defaults-arch.yml")
            Emulator.updateConfiguration(self.renderconfig, globalSettings)
            Emulator.updateConfiguration(self.renderconfig, systemSettings)
            eslog.log("shader file={}".format(self.renderconfig["shader"]))
        else:
            eslog.log("no shader")

    # to be updated for python3: https://gist.github.com/angstwad/bf22d1822c38a92ec0a9
    @staticmethod
    def dict_merge(dct, merge_dct):
        """ Recursive dict merge. Inspired by :meth:``dict.update()``, instead of
        updating only top-level keys, dict_merge recurses down into dicts nested
        to an arbitrary depth, updating keys. The ``merge_dct`` is merged into
        ``dct``.
        :param dct: dict onto which the merge is executed
        :param merge_dct: dct merged into dct
        :return: None
        """
        for k, v in merge_dct.iteritems():
            if (k in dct and isinstance(dct[k], dict) and isinstance(merge_dct[k], collections.Mapping)):
                Emulator.dict_merge(dct[k], merge_dct[k])
            else:
                dct[k] = merge_dct[k]

    @staticmethod
    def get_generic_config(system, defaultyml, defaultarchyml):
        systems_default      = yaml.load(file(defaultyml,     "r"))

        systems_default_arch = {}
        if os.path.exists(defaultarchyml):
            systems_default_arch = yaml.load(file(defaultarchyml, "r"))
        dict_all = {}

        if "default" in systems_default:
            dict_all = systems_default["default"]

        if "default" in systems_default_arch:
            Emulator.dict_merge(dict_all, systems_default_arch["default"])

        if system in systems_default:
            Emulator.dict_merge(dict_all, systems_default[system])

        if system in systems_default_arch:
            Emulator.dict_merge(dict_all, systems_default_arch[system])

        return dict_all

    @staticmethod
    def get_system_config(system, defaultyml, defaultarchyml):
        dict_all = Emulator.get_generic_config(system, defaultyml, defaultarchyml)

        # options are in the yaml, not in the system structure
        # it is flat in the batocera.conf which is easier for the end user, but i prefer not flat in the yml files
        dict_result = {"emulator": dict_all["emulator"], "core": dict_all["core"]}
        if "options" in dict_all:
            Emulator.dict_merge(dict_result, dict_all["options"])
        return dict_result

    def isOptSet(self, key):
        return key in self.config

    def getOptBoolean(self, key):
        if unicode(self.config[key]) == u'1':
            return True
        if unicode(self.config[key]) == u'true':
            return True
        if self.config[key] == True:
            return True
        return False

    @staticmethod
    def updateConfiguration(config, settings):
        # ignore all values "default", "auto", "" to take the system value instead
        # ideally, such value must not be in the configuration file
        # but historically some user have them
        toremove = [k for k in settings if settings[k] == "" or settings[k] == "default" or settings[k] == "auto"]
        for k in toremove: del settings[k]

        config.update(settings)

    # fps value is from es
    def updateDrawFPS(self):
        try:
            esConfig = ET.parse(batoceraFiles.esSettings)
            value = esConfig.find("./bool[@name='DrawFramerate']").attrib["value"]
        except:
            value = 'false'
        if value not in ['false', 'true']:
            value = 'false'
        self.config['showFPS'] = value
