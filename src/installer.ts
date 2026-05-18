import { exec } from 'node:child_process';
import { promisify } from 'node:util';
import type { SystemInfo } from './system.js';

const execAsync = promisify(exec);

export async function performInstall(info: SystemInfo, log: (msg: string) => void): Promise<void> {
  const method = info.recommendedMethod;
  log(`Using recommended method: ${method}`);

  try {
    if (method === 'brew') {
      log('Running: brew install --cask google-antigravity');
      // await execAsync('brew install --cask google-antigravity');
      log('Mocked brew install successful.');
    } else if (method === 'repo') {
      if (info.packageManagers.apt) {
        log('Running: apt-get install antigravity');
        // await execAsync('sudo apt-get update && sudo apt-get install -y antigravity');
        log('Mocked apt install successful.');
      } else if (info.packageManagers.dnf) {
        log('Running: dnf install antigravity');
        // await execAsync('sudo dnf install -y antigravity');
        log('Mocked dnf install successful.');
      }
    } else {
      log('Downloading and extracting official binary tarball/dmg...');
      // Implement tarball extraction logic here based on OS
      log('Mocked tarball extraction successful.');
    }
  } catch (error: any) {
    throw new Error(`Command failed: ${error.message}`);
  }
}

export async function performUninstall(info: SystemInfo, log: (msg: string) => void): Promise<void> {
    log(`Attempting to uninstall based on platform: ${info.platform}`);
    try {
        if (info.platform === 'darwin' && info.packageManagers.brew) {
            log('Running: brew uninstall --cask google-antigravity');
            // await execAsync('brew uninstall --cask google-antigravity');
            log('Mocked brew uninstall successful.');
        } else if (info.platform === 'linux') {
            if (info.packageManagers.apt) {
                log('Running: apt-get remove antigravity');
                // await execAsync('sudo apt-get remove -y antigravity');
                log('Mocked apt uninstall successful.');
            } else {
                log('Removing local bin and lib folders...');
            }
        }
    } catch (error: any) {
        throw new Error(`Uninstall failed: ${error.message}`);
    }
}
