import dataclasses
import os
import os.path
import subprocess
import sys
from typing import List, Type

import libfoolang


@dataclasses.dataclass
class Testcase:
    """
    Each testcase runs the App subclass ``cls`` with the list of command line
    arguments ``args``.
    """
    label: str
    cls: Type[libfoolang.App]
    args: List[str]


class BasicApp(libfoolang.App):
    def process_unit(self, unit):
        unit.root.dump()
        print("")


class WithDefaultFiles(BasicApp):
    def default_get_files(self):
        return ["input1", "input2"]


class WithEventHandler(BasicApp):
    class MyEH(libfoolang.EventHandler):
        def unit_parsed_callback(self, context, unit, reparsed):
            print(f"> unit {os.path.basename(unit.filename)} parsed")

    def create_event_handler(self):
        return WithEventHandler.MyEH()


tests = [
    # Check the interaction between the "default_get_files" method and source
    # files passed on the command line.
    Testcase("nodefaults_noargs", BasicApp, []),
    Testcase("nodefaults_args", BasicApp, ["input3"]),
    Testcase("defaults_noargs", WithDefaultFiles, []),
    Testcase("defaults_args", WithDefaultFiles, ["input3"]),

    # Check that the "create_event_handler" method is used as expected
    Testcase("event_handler", WithEventHandler, ["input1", "input2"]),
]


if len(sys.argv) == 1:
    # If we ran this script through our path wrapper helper for Windows, run
    # the subprocess under this wrapper, too.
    path_wrapper = os.environ.get("PATH_WRAPPER")

    print("main.py: Starting...")
    print("")
    for t in tests:
        print(f"== {t.label} ==")
        print("")
        sys.stdout.flush()
        argv = [sys.executable, __file__, t.cls.__name__] + t.args
        if path_wrapper:
            argv.insert(1, path_wrapper)
        subprocess.check_call(argv)
    print("main.py: Done.")

else:
    clsname, args = sys.argv[1], sys.argv[2:]

    cls = globals()[clsname]
    cls.run(args)
