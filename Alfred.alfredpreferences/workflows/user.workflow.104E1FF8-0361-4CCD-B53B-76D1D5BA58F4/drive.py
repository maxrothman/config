from workflow import Workflow
from drive_api import Drive

UPDATE_SETTINGS = {'github_slug' : 'azai91/alfred-drive-workflow'}
HELP_URL = 'https://github.com/azai91/alfred-drive-workflow/issues'

wf = Workflow(update_settings=UPDATE_SETTINGS, help_url=HELP_URL)

def main(_):
    user_input = ""
    try:
        settings = True if wf.args[0][0] == '>' else False
    except:
        settings = False

    if wf.update_available:
        Drive.add_update()

    try:
        user_input = wf.args[0][1::].strip() if settings else wf.args[0]
    except:
        user_input = wf.args[0]

    if settings:
        Drive.show_settings(user_input)
    elif len(user_input):
        # try:
        Drive.show_items(user_input)
        # except: figure out speciic error, could be internet, login
            # Drive.show_options('login')
    elif len(user_input) == 0:
        Drive.show_options()
        Drive.refresh_list()


    return 0

if __name__ == '__main__':
    wf.run(main)