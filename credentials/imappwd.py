import os.path
import subprocess
home = os.path.expanduser("~")
def mailpasswd(acct):
  acct = os.path.basename(acct)
  path = "%s/.config/mutt/credentials/%s.gpg" % (home,acct)
  args = ["gpg2", "--use-agent", "--quiet", "--batch", "-d", path]
  try:
    return subprocess.check_output(args).strip()
  except subprocess.CalledProcessError:
      return ""
