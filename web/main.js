const { invoke } = window.__TAURI__.tauri;
const input = document.getElementById('commandInput');
const terminal = document.getElementById('terminal');

input.addEventListener('keypress', async (e) => {
    if (e.key === 'Enter') {
        const cmd = input.value;
        terminal.innerHTML += `<div>> ${cmd}</div>`;
        
        // This 'invoke' calls the 'ask_overseer' function in main.rs
        const response = await invoke('ask_overseer', { query: cmd });
        
        terminal.innerHTML += `<div>${response}</div>`;
        input.value = '';
        terminal.scrollTop = terminal.scrollHeight;
    }
});
