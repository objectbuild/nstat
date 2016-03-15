#! /usr/bin/env python3.4

import util.xml_utils
import os

CONTROLLER_DIR_NAME = 'distribution-karaf-0.3.1-Lithium-SR1'

def change_flow_timeouts():
    """ Set the minimum idle and hard flow timeouts in the controller's
    configuration file.
    """

    string_to_find_1 = 'reactive-flow-idle-timeout'
    string_to_find_2 = 'reactive-flow-hard-timeout'

    # path to xml config file
    input_file = os.path.sep.join([os.path.dirname(os.path.realpath(__file__)),
        CONTROLLER_DIR_NAME, 'etc', 'opendaylight', 'karaf',
        '58-l2switchmain.xml'])
    util.xml_utils.manipulate_xml(input_file, input_file, string_to_find_1,
                             '1')
    util.xml_utils.manipulate_xml(input_file, input_file, string_to_find_2,
                             '1')

def change_proactive_flow_mod():
    """ Unset proactive flow mod, in controller's configuration.
    """
    string_to_find = 'is-proactive-flood-mode'
    input_file = os.path.sep.join([os.path.dirname(os.path.realpath(__file__)),
        CONTROLLER_DIR_NAME, 'etc', 'opendaylight', 'karaf',
        '54-arphandler.xml'])
    util.xml_utils.manipulate_xml(input_file, input_file, string_to_find,
                             'false')

if __name__ == '__main__':
    change_flow_timeouts()
    change_proactive_flow_mod()