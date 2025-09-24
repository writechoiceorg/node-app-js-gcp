"""Targets in the repository root"""

load("@aspect_rules_js//js:defs.bzl", "js_library")
load("@gazelle//:def.bzl", "gazelle")
load("@npm//:defs.bzl", "npm_link_all_packages")
# Carrega a macro para criar o binário do Jest
load("@npm//:jest/package_json.bzl", jest_bin = "bin")

npm_link_all_packages(name = "node_modules")

# Cria um alvo executável para o Jest e o torna público
jest_bin.jest_binary(
    name = "jest_bin",
    visibility = ["//visibility:public"],
)

js_library(
    name = "eslintrc",
    srcs = ["eslint.config.mjs"],
    visibility = ["//:__subpackages__"],
    deps = [
        ":node_modules/@eslint/js",
        ":node_modules/typescript-eslint",
    ],
)

js_library(
    name = "prettierrc",
    srcs = ["prettier.config.cjs"],
    visibility = ["//tools/format:__pkg__"],
    deps = [],
)

gazelle(
    name = "gazelle",
    gazelle = "@multitool//tools/gazelle",
)

filegroup(
    name = "jest_config",
    srcs = ["jest.config.js"],
    visibility = ["//visibility:public"],
)