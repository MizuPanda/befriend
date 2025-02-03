module.exports = {
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    ecmaVersion: 2020,
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
    "quotes": ["error", "double", {"allowTemplateLiterals": true}],
    "indent": "off",
    "max-len": "off",
    "require-jsdoc": "off",
    "padded-blocks": "off",
  },
  overrides: [
    {
      files: ["**/*.spec.*"],
      env: {
        mocha: true,
      },
      rules: {},
    },
  ],
  globals: {},
};
