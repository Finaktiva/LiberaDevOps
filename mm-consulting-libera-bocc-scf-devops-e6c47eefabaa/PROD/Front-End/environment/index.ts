interface AmplifyConfig {
    readonly Auth: {
        readonly identityPoolId: string;
        readonly region: string;
        readonly userPoolId: string;
        readonly userPoolWebClientId: string;
    };
}

export interface AppRoutes {
    landing: string;
    admin: string;
    enterprise: string;
}

export abstract class EnvironmentConfig {
    abstract readonly production: boolean;
    abstract readonly mock: boolean;
    abstract readonly api: string;
    abstract readonly amplify: AmplifyConfig;
    abstract readonly routes: AppRoutes;
}

const API_ENDPOINT_DEV =
    'https://s0rxl4twgj.execute-api.us-west-2.amazonaws.com/dev';

const API_ENDPOINT_PROD =
    'https://iy7wvzhocb.execute-api.us-west-2.amazonaws.com/stage';

const AMPLIFY_AUTH_CONFIG_DEV: AmplifyConfig = {
    Auth: {
        identityPoolId: 'us-west-2:d065ba6d-caa2-40f9-9b4e-9a675cf54274',
        region: 'us-west-2',
        userPoolId: 'us-west-2_s0z6k1ipU',
        userPoolWebClientId: '58hvefr86km8ceriv7u3s02ll5',
    },
};

const AMPLIFY_AUTH_CONFIG_PROD: AmplifyConfig = {
    Auth: {
        identityPoolId: 'us-west-2:186279a4-245c-446e-921c-7e49575d395e',
        region: 'us-west-2',
        userPoolId: 'us-west-2_ojbXx5hu1',
        userPoolWebClientId: '5d9gq5i00tv5jli9hg4nn149rs',
    },
};

const APP_ROUTES_DEV: AppRoutes = {
    landing: 'http://localhost:4200',
    admin: 'http://localhost:4201',
    enterprise: 'http://localhost:4202',
};

const APP_ROUTES_PROD: AppRoutes = {
    landing: '/',
    admin: '/admin',
    enterprise: '/enterprise',
};

export const environment: EnvironmentConfig = {
    production: false,
    mock: false,
    api: API_ENDPOINT_DEV,
    amplify: AMPLIFY_AUTH_CONFIG_DEV,
    routes: APP_ROUTES_DEV,
};

export const environmentDev: EnvironmentConfig = {
    production: true,
    mock: false,
    api: API_ENDPOINT_DEV,
    amplify: AMPLIFY_AUTH_CONFIG_DEV,
    routes: APP_ROUTES_PROD,
};

export const environmentProd: EnvironmentConfig = {
    production: true,
    mock: false,
    api: API_ENDPOINT_PROD,
    amplify: AMPLIFY_AUTH_CONFIG_PROD,
    routes: APP_ROUTES_PROD,
};

export const environmentMock: EnvironmentConfig = {
    ...environment,
    mock: true,
};

export const PRODUCTION_PROVIDER = 'Production';

export const API_ENDPOINT_PROVIDER = 'API Endpoint';

export const SHOULD_MOCK_PROVIDER = 'Mock Environment';

export const APP_ROUTES_PROVIDER = 'App Routes';
