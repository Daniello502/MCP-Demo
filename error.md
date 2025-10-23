oot@bd4a2cb203ff:/app# python server.py
^C
Traceback (most recent call last):
  File "/usr/local/lib/python3.11/site-packages/anyio/streams/memory.py", line 111, in receive
    return self.receive_nowait()
           ^^^^^^^^^^^^^^^^^^^^^
  File "/usr/local/lib/python3.11/site-packages/anyio/streams/memory.py", line 106, in receive_nowait
    raise WouldBlock
anyio.WouldBlock

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "/usr/local/lib/python3.11/asyncio/runners.py", line 118, in run
    return self._loop.run_until_complete(task)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/local/lib/python3.11/asyncio/base_events.py", line 654, in run_until_complete
    return future.result()
           ^^^^^^^^^^^^^^^
  File "/app/server.py", line 188, in main
    await server_instance.server.run(
  File "/usr/local/lib/python3.11/site-packages/mcp/server/lowlevel/server.py", line 614, in run
    async with AsyncExitStack() as stack:
  File "/usr/local/lib/python3.11/contextlib.py", line 745, in __aexit__
    raise exc_details[1]
  File "/usr/local/lib/python3.11/contextlib.py", line 728, in __aexit__
    cb_suppress = await cb(*exc_details)
                  ^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/local/lib/python3.11/site-packages/mcp/shared/session.py", line 218, in __aexit__
    return await self._task_group.__aexit__(exc_type, exc_val, exc_tb)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/local/lib/python3.11/site-packages/anyio/_backends/_asyncio.py", line 785, in __aexit__
    raise exc_val
  File "/usr/local/lib/python3.11/site-packages/mcp/server/lowlevel/server.py", line 625, in run
    async with anyio.create_task_group() as tg:
  File "/usr/local/lib/python3.11/site-packages/anyio/_backends/_asyncio.py", line 785, in __aexit__
    raise exc_val
  File "/usr/local/lib/python3.11/site-packages/mcp/server/lowlevel/server.py", line 626, in run
    async for message in session.incoming_messages:
  File "/usr/local/lib/python3.11/site-packages/anyio/abc/_streams.py", line 41, in __anext__
    return await self.receive()
           ^^^^^^^^^^^^^^^^^^^^
  File "/usr/local/lib/python3.11/site-packages/anyio/streams/memory.py", line 119, in receive
    await receive_event.wait()
  File "/usr/local/lib/python3.11/asyncio/locks.py", line 213, in wait
    await fut
asyncio.exceptions.CancelledError

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "/app/server.py", line 201, in <module>
    asyncio.run(main())
  File "/usr/local/lib/python3.11/asyncio/runners.py", line 190, in run
    return runner.run(main)
           ^^^^^^^^^^^^^^^^
  File "/usr/local/lib/python3.11/asyncio/runners.py", line 123, in run
    raise KeyboardInterrupt()
KeyboardInterrupt

root@bd4a2cb203ff:/app# exit
exit