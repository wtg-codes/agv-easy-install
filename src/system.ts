import os from 'node:os';
import { execSync } from 'node:child_process';
import fs from 'node:fs';

export interface SystemInfo {
  platform: NodeJS.Platform;
  arch: string;
  release: string;
  isWSL: boolean;
  isCrostini: boolean;
  isDocker: boolean;
  packageManagers: {
    brew: boolean;
    apt: boolean;
    dnf: boolean;
  };
  recommendedMethod: string;
  antigravityInstalled: boolean;
}

export function gatherSystemInfo(): SystemInfo {
  const platform = os.platform();
  const arch = os.arch();
  const release = os.release();

  let isWSL = false;
  let isCrostini = false;
  let isDocker = false;

  if (platform === 'linux') {
    try {
      const releaseInfo = fs.readFileSync('/proc/sys/kernel/osrelease', 'utf8').toLowerCase();
      if (releaseInfo.includes('microsoft') || releaseInfo.includes('wsl')) {
        isWSL = true;
      }
    } catch {}

    try {
      if (fs.existsSync('/dev/lxd/sock') && fs.existsSync('/opt/google/cros-containers')) {
        isCrostini = true;
      }
    } catch {}

    try {
      if (fs.existsSync('/.dockerenv')) {
        isDocker = true;
      } else {
        const cgroup = fs.readFileSync('/proc/1/cgroup', 'utf8');
        if (cgroup.includes('docker') || cgroup.includes('lxc')) {
          isDocker = true;
        }
      }
    } catch {}
  }

  const packageManagers = {
    brew: hasCommand('brew'),
    apt: hasCommand('apt-get'),
    dnf: hasCommand('dnf'),
  };

  let recommendedMethod = 'binary';
  if (platform === 'darwin') recommendedMethod = 'brew';
  else if (platform === 'linux') {
    if (packageManagers.apt || packageManagers.dnf) {
      recommendedMethod = 'repo';
    }
  }

  const antigravityInstalled = checkAntigravityInstalled(platform);

  return {
    platform,
    arch,
    release,
    isWSL,
    isCrostini,
    isDocker,
    packageManagers,
    recommendedMethod,
    antigravityInstalled,
  };
}

function hasCommand(cmd: string): boolean {
  try {
    execSync(`command -v ${cmd}`, { stdio: 'ignore' });
    return true;
  } catch {
    return false;
  }
}

function checkAntigravityInstalled(platform: NodeJS.Platform): boolean {
  try {
    execSync('command -v antigravity', { stdio: 'ignore' });
    return true;
  } catch {
    if (platform === 'darwin') {
        return fs.existsSync('/Applications/Google Antigravity.app') || fs.existsSync('/Applications/Antigravity.app');
    }
    return false;
  }
}
