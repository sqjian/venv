#!/usr/bin/env bash
#[MISE] description="pull or push latest docker image."
#[MISE] dir="{{config_root}}"

POLICY_FILE="/etc/containers/policy.json"
if [ ! -f "$POLICY_FILE" ]; then
	mkdir -p "$(dirname "$POLICY_FILE")"
	cat >"$POLICY_FILE" <<-EOF
		{
		    "default": [
		        {
		            "type": "insecureAcceptAnything"
		        }
		    ],
		    "transports": {
		        "docker-daemon": {
		            "": [
		                {
		                    "type": "insecureAcceptAnything"
		                }
		            ]
		        }
		    }
		}
	EOF
fi
