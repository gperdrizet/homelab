import os


c = get_config()

c.ServerApp.ip = "0.0.0.0"
c.ServerApp.port = 47302
c.ServerApp.open_browser = False
c.ServerApp.allow_remote_access = True
c.ServerApp.trust_xheaders = True
c.ServerApp.root_dir = "/workspace"

# Public ingress terminates on gatekeeper nginx, but Jupyter must still require
# a password when reached at jupyter.perdrizet.org.
c.IdentityProvider.token = ""
c.PasswordIdentityProvider.hashed_password = os.environ.get("JUPYTER_PASSWORD_HASH", "")
