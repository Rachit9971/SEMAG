import { timerTrigger5 } from '../src/functions/timerTrigger5';
import { InvocationContext, Timer } from '@azure/functions';

// Mock the Azure Functions
jest.mock('@azure/functions', () => ({
  app: {
    timer: jest.fn()
  }
}));

describe('timerTrigger5 Function Tests', () => {
  let mockContext: InvocationContext;
  let mockTimer: Timer;

  beforeEach(() => {
    // Create mock context
    mockContext = {
      log: jest.fn(),
      bindingData: {},
      bindingDefinitions: [],
      bindings: {},
      functionName: 'timerTrigger5',
      invocationId: 'test-invocation',
      extraInputs: new Map(),
      extraOutputs: new Map(),
      options: {},
      triggerMetadata: {}
    } as any;

    // Create mock timer
    mockTimer = {
      schedule: {
        adjustForDST: true
      },
      scheduleStatus: {
        last: '2025-08-06T11:00:00.000Z',
        next: '2025-08-06T11:01:00.000Z',
        lastUpdated: '2025-08-06T11:00:00.000Z'
      },
      isPastDue: false
    } as Timer;

    // Clear all mocks
    jest.clearAllMocks();
  });

  test('should log timer function processed request', async () => {
    await timerTrigger5(mockTimer, mockContext);
    
    expect(mockContext.log).toHaveBeenCalledWith('Timer function processed request.');
  }, 10000); // 10 second timeout

  test('should complete successfully after timeout', async () => {
    const consoleSpy = jest.spyOn(console, 'log').mockImplementation();
    
    await timerTrigger5(mockTimer, mockContext);
    
    expect(consoleSpy).toHaveBeenCalledWith('HELLO HELLO HELLO HELLO HELLO HELLO');
    expect(mockContext.log).toHaveBeenCalledWith('Timer function completed after 5 seconds.');
    
    consoleSpy.mockRestore();
  }, 10000); // 10 second timeout for this test

  test('should handle timer properties correctly', async () => {
    expect(mockTimer.isPastDue).toBe(false);
    expect(mockTimer.scheduleStatus).toBeDefined();
    expect(mockTimer.scheduleStatus.next).toBeDefined();
  });
  
  test('should have valid context properties', async () => {
    await timerTrigger5(mockTimer, mockContext);
    
    expect(mockContext.functionName).toBe('timerTrigger5');
    expect(mockContext.invocationId).toBeDefined();
  }, 10000); // 10 second timeout
});
