#!/usr/bin/env node
import React from 'react';
import { render } from 'ink';
import meow from 'meow';
import { App } from './components/App.js';

const cli = meow(
  `
	Usage
	  $ agv-manager

	Options
	  --auto, -a       Install automatically without prompting
    --demo-ui        Run in sandbox mode to test the UI

	Examples
	  $ agv-manager
	  $ agv-manager --auto
`,
  {
    importMeta: import.meta,
    flags: {
      auto: {
        type: 'boolean',
        shortFlag: 'a',
      },
      demoUi: {
        type: 'boolean',
      },
    },
  }
);

const { auto } = cli.flags;

render(<App autoInstall={auto} />);
