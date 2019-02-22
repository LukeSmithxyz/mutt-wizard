import os.path
import subprocess
import distutils.spawn
home = os.path.expanduser("~")
def mailpasswd(acct):
  acct = os.path.basename(acct)
  path = "%s/.local/share/muttwizard/%s.gpg" % (home,acct)
  if distutils.spawn.find_executable("gpg"):
      GPG="gpg"
  else:
      GPG="gpg2"
  args = [GPG, "--use-agent", "--quiet", "--batch", "-d", path]
  try:
    return subprocess.check_output(args).strip().decode('UTF-8')
  except subprocess.CalledProcessError:
      return ""
