import json
import datetime
import sys

profiles = sys.argv[1:]
status_path = "/var/lib/resticprofile"


def get_status(profile):
    try:
        with open(f'{status_path}/{profile}.status', "r") as file:
            data = json.load(file)
    except FileNotFoundError:
        print("  N/A")
        exit()
    status = data["profiles"][profile]["backup"]
    status["profile"] = profile
    return status


def diff(time):
    now = datetime.datetime.now()
    then = datetime.datetime.fromisoformat(time).replace(tzinfo=None)
    return now - then


statuses = map(get_status, profiles)
status_labels = ["Failure", "Success"]

print("Backups:")
for status in statuses:
    time_ago = str(diff(status["time"]))[:-7]
    success = status_labels[status["success"]]
    print(f'  {status["profile"]}: ({success}) {time_ago} ago')
