#!/usr/bin/env python3

import argparse
import yaml
import os.path

parser = argparse.ArgumentParser()

parser.add_argument("local_registry_dir")
parser.add_argument("remote_registry_dir")
parser.add_argument("local_data_store")
parser.add_argument("local_cli_config")
parser.add_argument("global_cli_config")

args = parser.parse_args()

_local_cli_config = yaml.safe_load(open(args.local_cli_config))
_global_cli_config = yaml.safe_load(open(args.global_cli_config))

if args.remote_registry_dir != "default":
    _local_cli_config["registries"]["origin"]["token"] = os.path.join(
        args.remote_registry_dir,
        "token"
    )

    _global_cli_config["registries"]["origin"]["token"] = os.path.join(
        args.remote_registry_dir,
        "token"
    )

if args.local_registry_dir != "default":
    _global_cli_config["registries"]["local"]["token"] = os.path.join(
        args.local_registry_dir,
        "token"
    )

if args.local_data_store != "default":
    _global_cli_config["registries"]["local"]["data_store"] = args.local_data_store

yaml.dump(_global_cli_config, open(args.global_cli_config, 'w'))
yaml.dump(_local_cli_config, open(args.local_cli_config, 'w'))
