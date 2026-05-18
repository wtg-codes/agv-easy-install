import React from 'react';
import { Box, Text } from 'ink';
import SelectInput from 'ink-select-input';

interface ConfigBootstrapProps {
  onBack: () => void;
  onSelectConfig: (configType: string) => void;
}

export const ConfigBootstrap: React.FC<ConfigBootstrapProps> = ({ onBack, onSelectConfig }) => {
  const items = [
    { label: 'Setup Default MCPs', value: 'mcps' },
    { label: 'Setup Workflow Rules', value: 'workflows' },
    { label: 'Go Back', value: 'back' },
  ];

  const handleSelect = (item: { label: string; value: string }) => {
    if (item.value === 'back') {
      onBack();
    } else {
      onSelectConfig(item.value);
    }
  };

  return (
    <Box flexDirection="column" marginTop={1}>
      <Text bold color="magenta" >⚙️ Bootstrap Configurations</Text>
      <Text dimColor >Set up MCPs, workflow rules, and environment states.</Text>
      <SelectInput items={items} onSelect={handleSelect} />
    </Box>
  );
};
