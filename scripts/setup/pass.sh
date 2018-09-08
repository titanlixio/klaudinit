#!/bin/sh
python -c "from passlib.apps import custom_app_context as pwd_context; import getpass; print(pwd_context.encrypt(getpass.getpass()))"
