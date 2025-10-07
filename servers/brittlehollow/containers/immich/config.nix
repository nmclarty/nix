{ config, ... }: {
  sops = {
    secrets = {
      "immich/pocket/client" = {
        sopsFile = "${inputs.nix-secrets}/${config.networking.hostName}/podman.yaml";
        key = "immich/pocket/client";
      };
      "immich/pocket/secret" = {
        sopsFile = "${inputs.nix-secrets}/${config.networking.hostName}/podman.yaml";
        key = "immich/pocket/secret";
      };
    };
    templates."immich/config.json" = {
      restartunits = [ "immich.service" "immich-microservices.service" ];
      owner = "immich";
      content = ''
        {
          "ffmpeg": {
            "crf": 23,
            "threads": 0,
            "preset": "ultrafast",
            "targetVideoCodec": "h264",
            "acceptedVideoCodecs": ["h264"],
            "targetAudioCodec": "aac",
            "acceptedAudioCodecs": ["aac", "mp3", "libopus", "pcm_s16le"],
            "acceptedContainers": ["mov", "ogg", "webm"],
            "targetResolution": "1080",
            "maxBitrate": "0",
            "bframes": -1,
            "refs": 0,
            "gopSize": 0,
            "temporalAQ": false,
            "cqMode": "auto",
            "twoPass": false,
            "preferredHwDevice": "auto",
            "transcode": "required",
            "tonemap": "hable",
            "accel": "qsv",
            "accelDecode": true
          },
          "backup": {
            "database": {
              "enabled": true,
              "cronExpression": "0 02 * * *",
              "keepLastAmount": 14
            }
          },
          "job": {
            "backgroundTask": {
              "concurrency": 5
            },
            "smartSearch": {
              "concurrency": 8
            },
            "metadataExtraction": {
              "concurrency": 5
            },
            "faceDetection": {
              "concurrency": 8
            },
            "search": {
              "concurrency": 5
            },
            "sidecar": {
              "concurrency": 5
            },
            "library": {
              "concurrency": 5
            },
            "migration": {
              "concurrency": 5
            },
            "thumbnailGeneration": {
              "concurrency": 3
            },
            "videoConversion": {
              "concurrency": 4
            },
            "notifications": {
              "concurrency": 5
            }
          },
          "logging": {
            "enabled": true,
            "level": "log"
          },
          "machineLearning": {
            "enabled": true,
            "urls": ["http://immich-learning:3003"],
            "clip": {
              "enabled": true,
              "modelName": "ViT-SO400M-16-SigLIP2-384__webli"
            },
            "duplicateDetection": {
              "enabled": true,
              "maxDistance": 0.001
            },
            "facialRecognition": {
              "enabled": true,
              "modelName": "antelopev2",
              "minScore": 0.7,
              "maxDistance": 0.5,
              "minFaces": 10
            }
          },
          "map": {
            "enabled": true,
            "lightStyle": "https://tiles.immich.cloud/v1/style/light.json",
            "darkStyle": "https://tiles.immich.cloud/v1/style/dark.json"
          },
          "reverseGeocoding": {
            "enabled": true
          },
          "metadata": {
            "faces": {
              "import": false
            }
          },
          "oauth": {
            "autoLaunch": false,
            "autoRegister": true,
            "buttonText": "Login with OAuth",
            "clientId": "",
            "clientSecret": "",
            "defaultStorageQuota": null,
            "enabled": false,
            "issuerUrl": "",
            "mobileOverrideEnabled": false,
            "mobileRedirectUri": "",
            "scope": "openid email profile",
            "signingAlgorithm": "RS256",
            "profileSigningAlgorithm": "none",
            "storageLabelClaim": "preferred_username",
            "storageQuotaClaim": "immich_quota"
          },
          "passwordLogin": {
            "enabled": true
          },
          "storageTemplate": {
            "enabled": true,
            "hashVerificationEnabled": true,
            "template": "{{y}}/{{y}}-{{MM}}-{{dd}}/{{filename}}"
          },
          "image": {
            "thumbnail": {
              "format": "webp",
              "size": 250,
              "quality": 80
            },
            "preview": {
              "format": "jpeg",
              "size": 1440,
              "quality": 80
            },
            "colorspace": "p3",
            "extractEmbedded": false
          },
          "newVersionCheck": {
            "enabled": true
          },
          "trash": {
            "enabled": true,
            "days": 30
          },
          "theme": {
            "customCss": ""
          },
          "library": {
            "scan": {
              "enabled": true,
              "cronExpression": "0 0 * * *"
            },
            "watch": {
              "enabled": false
            }
          },
          "server": {
            "externalDomain": "https://immich.${config.private.domain}",
            "loginPageMessage": ""
          },
          "notifications": {
            "smtp": {
              "enabled": false,
              "from": "",
              "replyTo": "",
              "transport": {
                "ignoreCert": false,
                "host": "",
                "port": 587,
                "username": "",
                "password": ""
              }
            }
          },
          "user": {
            "deleteDelay": 7
          }
        }
      '';
    };
  };
}
