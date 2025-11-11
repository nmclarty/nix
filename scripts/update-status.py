import json
from datetime import datetime, timezone
from subprocess import run
import sys


def diff(channel):
    now = datetime.now()
    then = datetime.fromtimestamp(
      data["nodes"][channel]["locked"]["lastModified"])
    return [channel, now - then]


def parse_status(status: dict) -> dict:
    deployment = status["deployer"]["deployment"]
    generation = deployment["generation"]
    builder = status["builder"]["generation"]

    last_deployment = (
        datetime.now(tz=timezone.utc) -
        datetime.fromisoformat(deployment["ended_at"])
    )

    extra_info = [
        "Build failed" if builder["build_status"] == "failed" else "",
        "Testing" if generation["selected_branch_is_testing"] else "",
        "Reboot Required" if status["need_to_reboot"] else "",
        "Suspended" if status["is_suspended"] else "",
    ]

    return {
      "status": deployment["status"],
      "ago": str(last_deployment)[:-7] + " ago",
      "extra": ", ".join([i for i in extra_info if i != ""]),
      "msg": generation["selected_commit_msg"].rstrip(),
      "sha": generation["selected_commit_id"],
    }


# path to the lock file
flake_path = sys.argv[1] + "/flake.lock"
# the flake inputs to check
inputs = sys.argv[2:]

with open(flake_path, "r") as file:
    data = json.load(file)

last = map(diff, inputs)

status = parse_status(
    json.loads(run(["comin", "status", "--json"],
                   capture_output=True, text=True, check=True).stdout))

print("Updates: ")
print(f'  Status: ({status["status"]}) {status["ago"]} [{status["extra"]}]')
print(f'  Commit: ({status["sha"][:7]}) "{status["msg"]}"')
print("  Inputs:")
for i in last:
    print(f'    {i[0]}: {str(i[1])[:-7]} ago')
