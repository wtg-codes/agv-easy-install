import React from 'react';
import { Box, Text } from 'ink';
import type { SystemInfo } from '../system.js';
import chalk from 'chalk';

interface HeaderProps {
  systemInfo: SystemInfo;
}

export const Header: React.FC<HeaderProps> = ({ systemInfo }) => {
  return (
    <Box flexDirection="column" marginBottom={1} borderStyle="round" borderColor="cyan" padding={1}>
      <Text bold color="cyan">
        🚀 Google Antigravity Easy Install (Node.js/Ink Edition)
      </Text>
      <Text dimColor>One command. Any shell. We get you coding.</Text>

      <Box marginTop={1} flexDirection="column">
        <Text>
          <Text bold>System: </Text>
          {systemInfo.platform} {systemInfo.arch} ({systemInfo.release})
          {systemInfo.isWSL && chalk.yellow(' [WSL]')}
          {systemInfo.isDocker && chalk.yellow(' [Docker/Container]')}
          {systemInfo.isCrostini && chalk.yellow(' [ChromeOS Crostini]')}
        </Text>
        <Text>
          <Text bold>Package Managers: </Text>
          {Object.entries(systemInfo.packageManagers)
            .filter(([_, exists]) => exists)
            .map(([name]) => name)
            .join(', ') || 'None found'}
        </Text>
        <Text>
          <Text bold>Status: </Text>
          {systemInfo.antigravityInstalled ? chalk.green('Installed') : chalk.red('Not Installed')}
        </Text>
        <Text>
          <Text bold>Recommended Method: </Text>
          {systemInfo.recommendedMethod}
        </Text>
      </Box>
    </Box>
  );
};
