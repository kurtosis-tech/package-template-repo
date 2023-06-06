def run_hello(plan, config_json):
    # https://docs.kurtosis.com/starlark-reference/plan#add_service
    plan.add_service(
        name = "hello",
        config = ServiceConfig(
            image = "hello-world",
            files = {
                "/config": config_json,
            }
        )
    )
