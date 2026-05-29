from kittens.tui.handler import result_handler

def main(args):
    pass

@result_handler(no_ui=True)
def handle_result(args, _, __, boss):
    if len(args) < 2: return
    d = args[1]
    tm = boss.active_tab_manager
    if not tm or not boss.active_tab: return
    tabs = tm.tabs
    try:
        idx = tabs.index(boss.active_tab)
        n = len(tabs)
    except:
        return
    if d == "left":
        action = "tab-left" if idx > 0 else "new-tab-left"
    elif d == "right":
        action = "tab-right" if idx < n-1 else "new-tab-right"
    else:
        return
    boss.detach_window(action)
