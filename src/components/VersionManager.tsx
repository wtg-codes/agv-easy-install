import React from 'react';
import { Box, Text } from 'ink';
import SelectInput from 'ink-select-input';

interface VersionManagerProps {
  onBack: () => void;
  onSelectVersion: (version: string) => void;
}

export const VersionManager: React.FC<VersionManagerProps> = ({ onBack, onSelectVersion }) => {
  const items = [
    { label: 'Latest Stable (Recommended)', value: 'latest' },
    { label: 'Beta / Insiders', value: 'beta' },
    { label: 'Continuous Upgrade (Auto-update)', value: 'continuous' },
    { label: 'Go Back', value: 'back' },
  ];

  const handleSelect = (item: { label: string; value: string }) => {
    if (item.value === 'back') {
      onBack();
    } else {
      onSelectVersion(item.value);
    }
  };

  return (
    <Box flexDirection="column" marginTop={1}>
      <Text bold color="yellow" >📦 Version Management</Text>
      <SelectInput items={items} onSelect={handleSelect} />
    </Box>
  );
};
