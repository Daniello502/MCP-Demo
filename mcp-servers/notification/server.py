#!/usr/bin/env python3
"""
MCP Notification Server
Handles notifications and alerts for the service mesh
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
    ServerCapabilities,
)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class NotificationServer:
    def __init__(self):
        self.server = Server("notification")
        self.setup_handlers()
        self.notifications = []
        self.subscribers = []
    
    def setup_handlers(self):
        @self.server.list_tools()
        async def handle_list_tools() -> ListToolsResult:
            return ListToolsResult(
                tools=[
                    Tool(
                        name="send_notification",
                        description="Send a notification to subscribers",
                        inputSchema={
                            "type": "object",
                            "properties": {
                                "message": {
                                    "type": "string",
                                    "description": "Notification message"
                                },
                                "priority": {
                                    "type": "string",
                                    "enum": ["low", "medium", "high", "critical"],
                                    "description": "Notification priority"
                                },
                                "category": {
                                    "type": "string",
                                    "description": "Notification category"
                                }
                            },
                            "required": ["message", "priority"]
                        }
                    ),
                    Tool(
                        name="subscribe",
                        description="Subscribe to notifications",
                        inputSchema={
                            "type": "object",
                            "properties": {
                                "subscriber_id": {
                                    "type": "string",
                                    "description": "Unique subscriber identifier"
                                },
                                "filters": {
                                    "type": "object",
                                    "description": "Notification filters"
                                }
                            },
                            "required": ["subscriber_id"]
                        }
                    ),
                    Tool(
                        name="get_notifications",
                        description="Get recent notifications",
                        inputSchema={
                            "type": "object",
                            "properties": {
                                "limit": {
                                    "type": "integer",
                                    "description": "Maximum number of notifications to return"
                                },
                                "category": {
                                    "type": "string",
                                    "description": "Filter by category"
                                }
                            },
                            "required": []
                        }
                    )
                ]
            )
        
        @self.server.call_tool()
        async def handle_call_tool(name: str, arguments: Dict[str, Any]) -> CallToolResult:
            if name == "send_notification":
                return await self.send_notification(arguments)
            elif name == "subscribe":
                return await self.subscribe(arguments)
            elif name == "get_notifications":
                return await self.get_notifications(arguments)
            else:
                raise ValueError(f"Unknown tool: {name}")
    
    async def send_notification(self, arguments: Dict[str, Any]) -> CallToolResult:
        message = arguments["message"]
        priority = arguments["priority"]
        category = arguments.get("category", "general")
        
        notification = {
            "id": len(self.notifications) + 1,
            "message": message,
            "priority": priority,
            "category": category,
            "timestamp": asyncio.get_event_loop().time(),
            "subscribers_notified": len(self.subscribers)
        }
        
        self.notifications.append(notification)
        
        # Keep only last 100 notifications
        if len(self.notifications) > 100:
            self.notifications = self.notifications[-100:]
        
        result = {
            "notification_sent": True,
            "notification_id": notification["id"],
            "subscribers_notified": notification["subscribers_notified"]
        }
        
        return CallToolResult(
            content=[TextContent(type="text", text=json.dumps(result, indent=2))]
        )
    
    async def subscribe(self, arguments: Dict[str, Any]) -> CallToolResult:
        subscriber_id = arguments["subscriber_id"]
        filters = arguments.get("filters", {})
        
        subscriber = {
            "id": subscriber_id,
            "filters": filters,
            "subscribed_at": asyncio.get_event_loop().time()
        }
        
        # Remove existing subscription if any
        self.subscribers = [s for s in self.subscribers if s["id"] != subscriber_id]
        self.subscribers.append(subscriber)
        
        result = {
            "subscribed": True,
            "subscriber_id": subscriber_id,
            "total_subscribers": len(self.subscribers)
        }
        
        return CallToolResult(
            content=[TextContent(type="text", text=json.dumps(result, indent=2))]
        )
    
    async def get_notifications(self, arguments: Dict[str, Any]) -> CallToolResult:
        limit = arguments.get("limit", 10)
        category = arguments.get("category")
        
        filtered_notifications = self.notifications
        if category:
            filtered_notifications = [n for n in filtered_notifications if n["category"] == category]
        
        # Sort by timestamp (newest first) and limit
        filtered_notifications = sorted(
            filtered_notifications, 
            key=lambda x: x["timestamp"], 
            reverse=True
        )[:limit]
        
        result = {
            "notifications": filtered_notifications,
            "total_count": len(filtered_notifications),
            "category_filter": category
        }
        
        return CallToolResult(
            content=[TextContent(type="text", text=json.dumps(result, indent=2))]
        )

async def main():
    server_instance = NotificationServer()
    
    async with stdio_server() as (read_stream, write_stream):
        await server_instance.server.run(
            read_stream,
            write_stream,
            InitializationOptions(
                server_name="notification",
                server_version="1.0.0",
                capabilities=ServerCapabilities(
                    tools={}  
                )
            )
        )

if __name__ == "__main__":
    asyncio.run(main())
