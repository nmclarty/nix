from json import load, loads
from datetime import datetime, timezone, timedelta
from subprocess import run
from sys import argv


def calculate_diff(input: str) -> list[str | timedelta]:
    """Calculates the time difference between now and the last modified time of
    a nix flake input (i.e. nixpkgs).

    :param input: The nix flake input name to check
    :return: A list containing the input name and the time difference
    """
    then = datetime.fromtimestamp(
      flake_lock["nodes"][input]["locked"]["lastModified"])
    return [input, datetime.now() - then]


def parse_status(status: dict[str, dict]) -> dict[str, str]:
    """Extracts and transforms a dictionary containing the status received from
    Comin that will be formatted and displayed to the user.

    :param status: The parsed json status from Comin
    :return: The status fields to be formatted and displayed to the user
    """
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
flake_lock_path = argv[1] + "/flake.lock"
# the flake inputs to check
inputs = argv[2:]

# load the flake lock file
with open(flake_lock_path, "r") as file:
    flake_lock = load(file)

# load the status info in json from comin, and the parse it
status = parse_status(
    loads(run(["comin", "status", "--json"],
              capture_output=True, text=True, check=True).stdout))

# don't show extra info if there is none
extra_info = f' [{status["extra"]}]' if status["extra"] else ""

print("Updates: ")
print(f'  Status: ({status["status"]}) {status["ago"]}{extra_info}')
print(f'  Commit: ({status["sha"][:7]}) "{status["msg"]}"')
print("  Inputs:")
for i in map(calculate_diff, inputs):
    print(f'    {i[0]}: {str(i[1])[:-7]} ago')
