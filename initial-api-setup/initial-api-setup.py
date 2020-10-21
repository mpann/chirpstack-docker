import os
import sys
from argparse import ArgumentParser
import json
import logging


try:
    from stimio import ChirpstackApp
except (ImportError, SyntaxError):
    # You may adjust this path if needed
    sys.path.insert(1, os.path.join(
        sys.path[0], '..', '..', 'SIOT10050-stimio-automation-toolbox', 'stimio', 'communication', 'lns'))
    from chirpstack import ChirpstackApp


def display(what: str, ident: int, name: str):
    print("       - {} id: {:40} name: {:20}".format(what, ident, name))


if __name__ == '__main__':

    parser = ArgumentParser()
    parser.add_argument('-c', '--conf', type=str, required=True, help='config file')
    args = parser.parse_args()

    with open(args.conf) as f:
        config = json.load(f)

    # Configure logs
    logger = logging.getLogger("chirpstack")
    handler = logging.StreamHandler(sys.stdout)
    handler.setLevel(logging.INFO)
    logger.addHandler(handler)
    handler.setFormatter(logging.Formatter('%(asctime)s : %(message)s'))
    logger.setLevel(logging.INFO)

    cs_app = ChirpstackApp(**config["connect_opts"])

    orglist = cs_app.get_organization_list()

    print("Removing default organization")
    cs_app.rm_organization(orglist[0]['id'])

    print("Adding default STIMIO organization")
    idOrg = cs_app.add_organization("STIMIOrg")
    idNw = cs_app.add_network_server(
        config['default_network_server_name'],
        config['default_network_server_address'])
    idServProf = cs_app.add_service_profile(config['default_service_profile_name'], idNw, idOrg)
    idDevProf = cs_app.add_device_profile(config['default_device_profile_name'], idNw, idOrg)

    orglist = cs_app.get_organization_list()

    print('')  # \n to simplify reading

    sp = cs_app.get_service_profile_list(orgId=orglist[0]['id'], limit=1)
    dp = cs_app.get_device_profile_list(orgId=orglist[0]['id'], limit=1)
    nw = cs_app.get_network_server_list(orgId=orglist[0]['id'], limit=1)

    print(" (Customer) Organization id: {:40} name: {:20}".format(
        orglist[0]['id'], orglist[0]['name']))
    display("service profile", sp[0]['id'], sp[0]['name'])
    display("device profile ", dp[0]['id'], dp[0]['name'])
    display("network server ", nw[0]['id'], nw[0]['name'])
    print("\n")

    cs_app.exit()
