-- Create a database and schema where to store the PATs to connect to GitHub
CREATE DATABASE IF NOT EXISTS ADMIN_DB;
CREATE SCHEMA IF NOT EXISTS Security;
USE DATABASE ADMIN_DB;
USE SCHEMA SECURITY;

-- Create a secret to be able to connect to GitHub
CREATE OR REPLACE SECRET SnowflakeGitBoxPAT
    TYPE = PASSWORD
    USERNAME = 'PluralRaccoon'
    PASSWORD = 'github_pat_<pat number>';

-- Create the API Integration at the Account Level to grant access to the repo
USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE API INTEGRATION GitHubIntegrationMaster
    API_PROVIDER = git_https_api
    API_ALLOWED_PREFIXES = ('https://github.com/PluralRaccoon/')
    ALLOWED_AUTHENTICATION_SECRETS = ('ADMIN_DB.SECURITY.SnowflakeGitBoxPAT')
    ENABLED = TRUE;

-- Create the actual Git Repo inside the PUBLIC schema
USE SCHEMA PUBLIC;

CREATE OR REPLACE GIT REPOSITORY SnowflakeGitBox
    ORIGIN = 'https://github.com/PluralRaccoon/SnowflakeGitBox.git'
    API_INTEGRATION = GitHubIntegrationMaster
    GIT_CREDENTIALS = ADMIN_DB.SECURITY.SnowflakeGitBoxPAT;

-- Fetch the repo files wince Snowflake doesn't do it inmediatelly.
-- Sync the repository with GitHub
ALTER GIT REPOSITORY SnowflakeGitBox FETCH;

-- View the actual files pulled from GitHub
LIST @SnowflakeGitBoxPAT/branches/main;
