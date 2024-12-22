# github-container-runner

Containerfile for the creation of a GitHub Actions runner.

## Systemd Quadlet

After each run the container is removed and replaced with a new one.

1. Create a user which should run this container
2. Enable lingering for that user
3. enable podman.socket for that user with  
`systemctl --user enable --now podman.socket`
4. create a podman secret with the name `github-token` which contains a GitHub Token with the capability to register new runners
5. create `gh-runner@.container` Quadlet in _~/.config/container/systemd_ which should contain: 

```unit file (systemd)
[Unit]
Description=GitHub action runner for %I

[Container]
AutoUpdate=registry
Image=docker.io/expeditioneer/github-container-runner:24.04
Timezone=Europe/Berlin
Environment=RUNNER_NAME=_YOUR_RUNNER_NAME_
Environment=REPO=%I
Secret=github-token,type=env,target=TOKEN
Volume=${XDG_RUNTIME_DIR}/podman/podman.sock:/run/docker.sock
Unmask=all
SecurityLabelDisable=true
AddCapability=all
SeccompProfile=unconfined

[Service]
Restart=always

[Install]
WantedBy=default.target
```

6. create symlink for desired org/repo which should use this custom runner and replace the '/' with '-'  
Example: if you want to use the self-hosted container runner for _my_org/my_repo_ your command would be  
`ln -s gh-runner\@.container gh-runner\@my_org-my_repo.container`
