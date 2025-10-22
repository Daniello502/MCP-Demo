#!/usr/bin/env python3
"""
MCP Data Processor Server
Processes and analyzes data from various sources
"""

import asyncio
import json
import logging
from typing import Any, Dict, List
from mcp.server import Server
from mcp.server.models import InitializationOptions
from mcp.server.stdio import stdio_server
from mcp.types import (
    CallToolRequest,
    CallToolResult,
    ListToolsRequest,
    ListToolsResult,
    Tool,
    TextContent,
)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class DataProcessorServer:
    def __init__(self):
        self.server = Server("data-processor")
        self.setup_handlers()
        self.processed_data = []
    
    def setup_handlers(self):
        @self.server.list_tools()
        async def handle_list_tools() -> ListToolsResult:
            return ListToolsResult(
                tools=[
                    Tool(
                        name="process_data",
                        description="Process and analyze data from various sources",
                        inputSchema={
                            "type": "object",
                            "properties": {
                                "data": {
                                    "type": "string",
                                    "description": "JSON data to process"
                                },
                                "operation": {
                                    "type": "string",
                                    "enum": ["analyze", "transform", "validate"],
                                    "description": "Type of operation to perform"
                                }
                            },
                            "required": ["data", "operation"]
                        }
                    ),
                    Tool(
                        name="get_statistics",
                        description="Get processing statistics",
                        inputSchema={
                            "type": "object",
                            "properties": {},
                            "required": []
                        }
                    )
                ]
            )
        
        @self.server.call_tool()
        async def handle_call_tool(name: str, arguments: Dict[str, Any]) -> CallToolResult:
            if name == "process_data":
                return await self.process_data(arguments)
            elif name == "get_statistics":
                return await self.get_statistics()
            else:
                raise ValueError(f"Unknown tool: {name}")
    
    async def process_data(self, arguments: Dict[str, Any]) -> CallToolResult:
        try:
            data = json.loads(arguments["data"])
            operation = arguments["operation"]
            
            result = {
                "operation": operation,
                "input_size": len(str(data)),
                "timestamp": asyncio.get_event_loop().time()
            }
            
            if operation == "analyze":
                result["analysis"] = {
                    "fields": len(data) if isinstance(data, dict) else 0,
                    "complexity": "high" if len(str(data)) > 1000 else "low"
                }
            elif operation == "transform":
                result["transformation"] = "Data transformed successfully"
            elif operation == "validate":
                result["validation"] = "Data is valid" if data else "Data is invalid"
            
            self.processed_data.append(result)
            
            return CallToolResult(
                content=[TextContent(type="text", text=json.dumps(result, indent=2))]
            )
            
        except Exception as e:
            logger.error(f"Error processing data: {e}")
            return CallToolResult(
                content=[TextContent(type="text", text=f"Error: {str(e)}")]
            )
    
    async def get_statistics(self) -> CallToolResult:
        stats = {
            "total_processed": len(self.processed_data),
            "operations": {
                "analyze": len([p for p in self.processed_data if p["operation"] == "analyze"]),
                "transform": len([p for p in self.processed_data if p["operation"] == "transform"]),
                "validate": len([p for p in self.processed_data if p["operation"] == "validate"])
            }
        }
        
        return CallToolResult(
            content=[TextContent(type="text", text=json.dumps(stats, indent=2))]
        )

async def main():
    server_instance = DataProcessorServer()
    
    async with stdio_server() as (read_stream, write_stream):
        await server_instance.server.run(
            read_stream,
            write_stream,
            InitializationOptions(
                server_name="data-processor",
                server_version="1.0.0",
                capabilities=server_instance.server.get_capabilities(
                    notification_options={},
                    experimental_capabilities={}
                )
            )
        )

if __name__ == "__main__":
    asyncio.run(main())
