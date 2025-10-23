  + Exception Group Traceback (most recent call last):
  |   File "/app/server.py", line 199, in <module>
  |     asyncio.run(main())
  |   File "/usr/local/lib/python3.11/asyncio/runners.py", line 190, in run
  |     return runner.run(main)
  |            ^^^^^^^^^^^^^^^^
  |   File "/usr/local/lib/python3.11/asyncio/runners.py", line 118, in run
  |     return self._loop.run_until_complete(task)
  |            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  |   File "/usr/local/lib/python3.11/asyncio/base_events.py", line 654, in run_until_complete
  |     return future.result()
  |            ^^^^^^^^^^^^^^^
  |   File "/app/server.py", line 184, in main
  |     async with stdio_server() as (read_stream, write_stream):
  |   File "/usr/local/lib/python3.11/contextlib.py", line 231, in __aexit__
  |     await self.gen.athrow(typ, value, traceback)
  |   File "/usr/local/lib/python3.11/site-packages/mcp/server/stdio.py", line 85, in stdio_server
  |     async with anyio.create_task_group() as tg:
  |   File "/usr/local/lib/python3.11/site-packages/anyio/_backends/_asyncio.py", line 781, in __aexit__
  |     raise BaseExceptionGroup(
  | ExceptionGroup: unhandled errors in a TaskGroup (1 sub-exception)
  +-+---------------- 1 ----------------
    | Traceback (most recent call last):
    |   File "/usr/local/lib/python3.11/site-packages/mcp/server/stdio.py", line 88, in stdio_server
    |     yield read_stream, write_stream
    |   File "/app/server.py", line 191, in main
    |     capabilities=server_instance.server.get_capabilities(
    |                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    |   File "/usr/local/lib/python3.11/site-packages/mcp/server/lowlevel/server.py", line 212, in get_capabilities
    |     tools_capability = types.ToolsCapability(listChanged=notification_options.tools_changed)
    |                                                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    | AttributeError: 'dict' object has no attribute 'tools_changed'