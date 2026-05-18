import React, { useState } from 'react';
import { Box, Text } from 'ink';
import SelectInput from 'ink-select-input';

interface MainMenuProps {
  onSelect: (value: string) => void;
}

export const MainMenu: React.FC<MainMenuProps> = ({ onSelect }) => {
  const items = [
    { label: 'Install Antigravity', value: 'install' },
    { label: 'Uninstall Antigravity', value: 'uninstall' },
    { label: 'Version Management', value: 'versions' },
    { label: 'Bootstrap Configuration', value: 'bootstrap' },
    { label: 'Exit', value: 'exit' },
  ];

  const handleSelect = (item: { label: string; value: string }) => {
    onSelect(item.value);
  };

  return (
    <Box flexDirection="column" marginTop={1}>
      <Text bold >Please choose an option:</Text>
      <SelectInput items={items} onSelect={handleSelect} />
    </Box>
  );
};
