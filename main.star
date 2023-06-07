# NOTE: If you're a VSCode user, you might like our VSCode extension: https://marketplace.visualstudio.com/items?itemName=Kurtosis.kurtosis-extension

# https://docs.kurtosis.com/starlark-reference/import-module
# TODO replace the 'github.com/kurtosis-tech/package-template-repo' below with your Github username and repo name
lib = import_module("github.com/kurtosis-tech/package-template-repo/lib/lib.star")

NAME_ARG = "name"

# For more information on...
#  - the 'run' function:  https://docs.kurtosis.com/concepts-reference/packages#runnable-packages
#  - the 'plan' object:   https://docs.kurtosis.com/starlark-reference/plan
#  - the 'args' object:   https://docs.kurtosis.com/next/concepts-reference/args
def run(plan, args):
    name = args.get(NAME_ARG, "John Snow")
    plan.print("Hello, " + name)

    # https://docs.kurtosis.com/starlark-reference/plan#upload_files
    # TODO replace the 'github.com/kurtosis-tech/package-template-repo' below with your Github username and repo name
    config_json = plan.upload_files("github.com/kurtosis-tech/package-template-repo/static-files/config.json")

    lib.run_hello(plan, config_json)
