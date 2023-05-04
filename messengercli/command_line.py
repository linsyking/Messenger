from messengercli.messenger import app


def main():
    try:
        app()
    except Exception as e:
        print(e)
