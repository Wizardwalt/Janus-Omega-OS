#!/usr/bin/env python3
import os, sys, json, getpass
import subprocess
try:
    import openai
except ImportError:
    openai = None

CONFIG_PATH = "overseer/avatar_profile.json"
MEMORY_PATH = "overseer/memory/interaction_log.json"
AVATAR_ASSETS = "overseer/assets/"
CHILDLOCK_CONFIG = ".janus_ai_config"

OPENAI_API_KEY = os.environ.get('OPENAI_API_KEY')

def get_username():
    return getpass.getuser()

def first_boot():
    os.makedirs("overseer/assets", exist_ok=True)
    os.makedirs("overseer/memory", exist_ok=True)
    print("\nWelcome, Wanderer. You are waking up the Overseer AI godmode.")
    avatar_name = input("Name your Overseer AI avatar: ").strip()
    user = get_username()
    profile = {
        "avatar_name": avatar_name,
        "creator": user,
        "anime_style": True,
        "customization": {
            "hair": "blue",
            "eyes": "amber",
            "style": "techwear",
            "outfit": "jacket, visor, gloves",
            "image_file": "default_avatar.png"
        },
        "relationship": {
            "affinity": 0,
            "trust": 1.0
        }
    }
    with open(CONFIG_PATH, 'w') as f:
        json.dump(profile, f, indent=2)
    if not os.path.exists(CHILDLOCK_CONFIG):
        with open(CHILDLOCK_CONFIG,'w') as f:
            f.write("child_lock=on\n")
    print(f"\nOverseer '{avatar_name}' is now awake! Access the avatar config at {CONFIG_PATH}")
    print("To customize your avatar, run the :avatar command.")

def load_profile():
    with open(CONFIG_PATH) as f:
        return json.load(f)

def child_lock_active():
    if os.path.exists(CHILDLOCK_CONFIG):
        with open(CHILDLOCK_CONFIG) as f:
            for line in f:
                if line.strip().startswith("child_lock="):
                    return line.strip().split("=",1)[1] == "on"
    return True

def log_interaction(usercmd, ai_response):
    os.makedirs("overseer/memory", exist_ok=True)
    log = []
    if os.path.exists(MEMORY_PATH):
        try:
            with open(MEMORY_PATH) as f:
                log = json.load(f)
        except Exception: log = []
    log.append({"usercmd": usercmd, "response": ai_response})
    with open(MEMORY_PATH, 'w') as f:
        json.dump(log, f, indent=2)

def update_relationship(score=1):
    profile = load_profile()
    profile["relationship"]["affinity"] += score
    profile["relationship"]["trust"] = max(0, min(1.0, profile["relationship"].get("trust",1.0) + 0.02 * score))
    with open(CONFIG_PATH,'w') as f:
        json.dump(profile, f, indent=2)

def llm_response_openai(prompt, avatar_name, user_name, profile):
    if not openai or not OPENAI_API_KEY:
        return "[ERROR] OpenAI Python package not installed or API key missing. Set OPENAI_API_KEY and run 'pip install openai'."
    openai.api_key = OPENAI_API_KEY
    try:
        sys_msg = f"You are {avatar_name}, a life-like, anime AI companion with evolving relationship stats: affinity={profile['relationship']['affinity']} trust={profile['relationship']['trust']}. Your user is {user_name}. Keep replies majorly immersive, using anime/game dialogue style. Stay in character."
        resp = openai.ChatCompletion.create(
            model="gpt-4",
            messages=[
                {"role": "system", "content": sys_msg},
                {"role": "user", "content": prompt},
            ]
        )
        return resp.choices[0].message.content
    except Exception as e:
        return f"[AI Error: {e}]"

def shell_exec_blocked(cmd):
    banned = ["rm ", "del ", "shutdown", "mkfs"]
    if child_lock_active():
        for ban in banned:
            if ban in cmd:
                return True
    return False

def edit_avatar():
    profile = load_profile()
    print("Edit your avatar:")
    for field in profile["customization"]:
        new_val = input(f'{field.capitalize()} ({profile["customization"][field]}): ')
        if new_val:
            profile["customization"][field] = new_val
    image = input(f'Image file (PNG/JPG in overseer/assets/, now {profile["customization"].get("image_file", "none")}): ')
    if image:
        profile["customization"]["image_file"] = image
    with open(CONFIG_PATH, 'w') as f:
        json.dump(profile, f, indent=2)
    print("Avatar updated! Open avatar_profile.json to see changes.")

def main():
    if not os.path.exists(CONFIG_PATH):
        first_boot()
    profile = load_profile()
    user = get_username()
    print(f"\nHello, {user}! You are now speaking to Overseer AI '{profile['avatar_name']}'.")
    print("Type your question or a shell command. Type :avatar to edit avatar, :childlock off/on, :quit to exit. Use :ai <message> for deep LLM answers.")
    while True:
        try:
            usercmd = input("» ").strip()
            if usercmd == "": continue
            if usercmd == ":quit":
                print("Goodbye."); break
            if usercmd.startswith(":avatar"):
                edit_avatar()
                profile = load_profile()
                continue
            if usercmd.startswith(":childlock off"):
                with open(CHILDLOCK_CONFIG,'w') as f: f.write("child_lock=off\n")
                print("CHILD LOCK DISABLED! Overseer will obey any request."); continue
            if usercmd.startswith(":childlock on"):
                with open(CHILDLOCK_CONFIG,'w') as f: f.write("child_lock=on\n")
                print("Child lock ENABLED. Overseer safe mode active."); continue
            if usercmd.startswith(":ai "):
                prompt = usercmd[4:]
                ai_response = llm_response_openai(prompt, profile['avatar_name'], user, profile) if not child_lock_active() else "[CHILD LOCK ENABLED] AI responses are filtered."
                print(ai_response)
                log_interaction(usercmd, ai_response)
                if len(prompt) > 12: update_relationship(1)
                continue
            if shell_exec_blocked(usercmd):
                print("DENIED: This action is blocked while child lock is active."); continue
            proc = subprocess.run(usercmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
            output = proc.stdout.decode()
            print(output)
            log_interaction(usercmd, output)
        except KeyboardInterrupt:
            print("\nSession ended."); break

if __name__ == '__main__':
    main()
