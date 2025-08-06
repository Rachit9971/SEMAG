import { app, InvocationContext, Timer } from "@azure/functions";

export async function timerTrigger5(myTimer: Timer, context: InvocationContext): Promise<void> {
    context.log('Timer function processed request.');
    console.log('HELLO HELLO HELLO HELLO HELLO HELLO');
    return new Promise((resolve) => {
        setTimeout(() => {
            context.log('Timer function completed after 5 seconds.');
            resolve();
        }, 5000);
    });
}

app.timer('timerTrigger5', {
    schedule: '0 */1 * * * *',
    handler: timerTrigger5
});
