#   Copyright 2014-present PUNCH Cyber Analytics Group
# 
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

"""
Overview
========

Monitor a directory for newly created files for processing

"""
import os
from pathlib import Path
from time import sleep
from asyncio import Queue
from watchgod import awatch
from typing import Dict, Optional

from stoq import Payload, PayloadMeta
from stoq.plugins import ProviderPlugin
from stoq.helpers import StoqConfigParser
from stoq.exceptions import StoqPluginException


class DirmonPlugin(ProviderPlugin):
    def __init__(self, config: StoqConfigParser) -> None:
        super().__init__(config)

        self.delay = config.getint('options', 'delay', fallback=1)
        self.source_dir = config.get('options', 'source_dir', fallback=None)
        if not self.source_dir or not os.path.exists(self.source_dir):
            raise StoqPluginException(
                f"Source directory not defined or doesn't exist: '{self.source_dir}'"
            )
        self.source_dir = os.path.abspath(self.source_dir)

    async def ingest(self, queue: Queue) -> None:
        """
        Monitor a directory for newly created files for ingest

        """

        self.log.info(f'Monitoring {self.source_dir} for newly created files...')
        async for changes in awatch(self.source_dir):
            for change in list(changes):
                event = change[0]
                src_path = Path(change[1])
                size = src_path.stat().st_size
                # Only handle Change.added
                if event != 1:
                    continue
                meta = PayloadMeta(
                    extra_data={
                        'filename': src_path.name,
                        'source_dir': str(src_path.resolve().parent)
                    }
                )
                sleep(5)
                while size != src_path.stat().st_size:
                    self.log.debug(f"{size} != {src_path.stat().st_size}")
                    sleep(5)
                    size = src_path.stat().st_size
                with src_path.open('rb') as f:
                    payload = Payload(f.read(), meta)
                    await queue.put(payload)
