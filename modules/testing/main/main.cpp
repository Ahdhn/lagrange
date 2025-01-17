/*
 * Copyright 2020 Adobe. All rights reserved.
 * This file is licensed to you under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License. You may obtain a copy
 * of the License at http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 * OF ANY KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 */
#include <catch2/catch_session.hpp>

#include <lagrange/Logger.h>
#include <lagrange/utils/fpe.h>

int main(int argc, char* argv[])
{
    Catch::Session session;
    int log_level = spdlog::level::warn;
    bool fpe_flag = false;

    auto cli = session.cli()
        | Catch::Clara::Opt(log_level, "log level")["-l"]["--log-level"]("Log level")
        | Catch::Clara::Opt(fpe_flag, "use fpe")["--enable-fpe"]("Enable FPE");

    session.cli(cli);

    if (auto ret = session.applyCommandLine(argc, argv)) {
        return ret;
    }

    log_level = std::max(0, std::min(6, log_level));
    lagrange::logger().set_level(static_cast<spdlog::level::level_enum>(log_level));

    if (fpe_flag) {
        lagrange::logger().info("Enabling floating point exceptions");
        lagrange::enable_fpe();
    }

    const auto session_ret = session.run();

    return session_ret;
}
