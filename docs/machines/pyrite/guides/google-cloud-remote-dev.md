# VS Code and Google Cloud Remote Development

Reference workflow for using VS Code remote SSH development against a Google
Cloud Compute Engine VM from pyrite.

## Scope

This guide is for optional cloud development workflows. It is not required for
homelab core operations.

## 1. Google Cloud CLI

Install dependencies:

```bash
sudo apt install apt-transport-https ca-certificates gnupg curl
```

Add Google Cloud apt key and repository:

```bash
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
```

Install CLI:

```bash
sudo apt update
sudo apt install google-cloud-cli
```

Initialize:

```bash
gcloud init
gcloud auth login
```

## 2. SSH access to Compute Engine

Connect once with gcloud:

```bash
gcloud compute ssh --zone "us-central1-c" "vostok" --project "ask-agatha"
```

Generate SSH config entries:

```bash
gcloud compute config-ssh
```

Then connect directly:

```bash
ssh vostok.us-central1-c.ask-agatha
```

## 3. VS Code remote workflow

- Open VS Code.
- Use Remote Explorer -> Remotes (Tunnels/SSH).
- Connect to the generated host from `~/.ssh/config`.
- Open project folder on the remote VM.

## 4. Optional VM lifecycle commands

```bash
gcloud compute instances start "vostok" --zone="us-central1-c"
gcloud compute instances stop "vostok" --zone="us-central1-c"
```

## 5. Environment bootstrap on VM

Typical baseline setup:

```bash
sudo apt update && sudo apt upgrade
sudo apt install git
```

Docker Engine can be installed from Docker's apt repository if needed for the
project workload.

## 6. Operational notes

- Stop cloud instances when idle to control cost.
- Treat VM-local files as ephemeral unless committed/pushed elsewhere.
- Keep secrets and keys out of project repositories.
