import React, { useState, useEffect } from 'react';
import { Box, Text, useApp } from 'ink';
import { Header } from './Header.js';
import { MainMenu } from './MainMenu.js';
import { VersionManager } from './VersionManager.js';
import { ConfigBootstrap } from './ConfigBootstrap.js';
import { gatherSystemInfo, SystemInfo } from '../system.js';
import { performInstall, performUninstall } from '../installer.js';

type ViewState = 'menu' | 'installing' | 'uninstalling' | 'versions' | 'bootstrap' | 'done';

interface AppProps {
  autoInstall?: boolean;
}

export const App: React.FC<AppProps> = ({ autoInstall }) => {
  const { exit } = useApp();
  const [systemInfo, setSystemInfo] = useState<SystemInfo | null>(null);
  const [view, setView] = useState<ViewState>('menu');
  const [logs, setLogs] = useState<string[]>([]);

  useEffect(() => {
    const info = gatherSystemInfo();
    setSystemInfo(info);

    if (autoInstall) {
      handleInstall(info);
    }
  }, [autoInstall]);

  const addLog = (msg: string) => {
    setLogs((prev) => [...prev, msg]);
  };

  const handleInstall = async (info: SystemInfo) => {
    setView('installing');
    addLog('Starting installation...');
    try {
      await performInstall(info, addLog);
      addLog('✅ Installation complete!');
    } catch (err: any) {
      addLog(`❌ Installation failed: ${err.message}`);
    }
    setTimeout(() => exit(), 2000);
  };

  const handleUninstall = async (info: SystemInfo) => {
    setView('uninstalling');
    addLog('Starting uninstallation...');
    try {
      await performUninstall(info, addLog);
      addLog('✅ Uninstallation complete!');
    } catch (err: any) {
      addLog(`❌ Uninstallation failed: ${err.message}`);
    }
    setTimeout(() => exit(), 2000);
  };

  if (!systemInfo) return <Text>Loading system info...</Text>;

  return (
    <Box flexDirection="column" padding={1}>
      <Header systemInfo={systemInfo} />

      {view === 'menu' && (
        <MainMenu
          onSelect={(val) => {
            if (val === 'install') handleInstall(systemInfo);
            else if (val === 'uninstall') handleUninstall(systemInfo);
            else if (val === 'versions') setView('versions');
            else if (val === 'bootstrap') setView('bootstrap');
            else if (val === 'exit') exit();
          }}
        />
      )}

      {view === 'versions' && (
        <VersionManager
          onBack={() => setView('menu')}
          onSelectVersion={(v) => {
            addLog(`Selected version strategy: ${v}`);
            setView('menu');
          }}
        />
      )}

      {view === 'bootstrap' && (
        <ConfigBootstrap
          onBack={() => setView('menu')}
          onSelectConfig={(c) => {
            addLog(`Selected config strategy: ${c}`);
            setView('menu');
          }}
        />
      )}

      {(view === 'installing' || view === 'uninstalling') && (
        <Box flexDirection="column" marginTop={1}>
          {logs.map((log, i) => (
            <Text key={i}>{log}</Text>
          ))}
        </Box>
      )}

      {view === 'menu' && logs.length > 0 && (
         <Box flexDirection="column" marginTop={1}>
           {logs.map((log, i) => (
            <Text dimColor key={i}>{log}</Text>
           ))}
         </Box>
      )}
    </Box>
  );
};
