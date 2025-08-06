// Test setup file
import { jest } from '@jest/globals';

// Mock Azure Functions context for testing
global.mockContext = {
  log: jest.fn(),
  bindingData: {},
  bindingDefinitions: [],
  bindings: {},
  executionContext: {
    functionName: 'test',
    functionDirectory: '/test',
    invocationId: 'test-id'
  }
};
