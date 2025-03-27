#include <flutter_linux/flutter_linux.h>

#include "include/vpnclient_engine_flutter/vpnclient_engine_flutter_plugin.h"

// This file exposes some plugin internals for unit testing. See
// https://github.com/flutter/flutter/issues/88724 for current limitations
// in the unit-testable API.

// Handles the getPlatformVersion method call.
FlMethodResponse *get_platform_version();
