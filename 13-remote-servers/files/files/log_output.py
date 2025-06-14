import datetime

# Define a list of log entries
log_entries = [
    "[INFO] System boot successful. All systems operational.",
    "[INFO] User 'root' logged in.",
    "[WARNING] User 'root' attempted to access 'sudo rm -rf /'. Operation blocked.",
    "[INFO] User 'root' logged out.",
    "[INFO] User 'guest' logged in.",
    "[INFO] User 'guest' attempted to install 'Fortnite'. Not enough disk space.",
    "[ERROR] User 'guest' attempted to delete 'system32'. Operation not permitted.",
    "[INFO] User 'guest' logged out.",
    "[INFO] System shutdown initiated.",
    "[INFO] System shutdown successful. Good night!"
]

# Get the current date and time
now = datetime.datetime.now()

# Modify the path to write the log file in the '/tmp/' directory
with open("/tmp/funny_log.txt", "w") as file:
    for entry in log_entries:
        # Write each log entry to the file with a timestamp
        file.write(f"{now.strftime('%Y-%m-%d %H:%M:%S')} {entry}\n")

print("Funny log file created in '/tmp/' directory.")
