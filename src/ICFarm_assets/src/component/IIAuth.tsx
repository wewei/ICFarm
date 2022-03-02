import { AuthClient } from "@dfinity/auth-client";
import { Identity } from "@dfinity/agent";
import { ComponentType, useEffect, useState } from "react";

export type AnonymousViewProps = {
  error?: string;
  login: () => void;
};

export type AuthenticatedViewProps = {
  identity: Identity;
  logout: () => void;
};

export type PreparingViewProps = Record<string, never>;

export type AuthenticatingViewProps = Record<string, never>;

export type AuthOptions = {
  maxTimeToLive: bigint;
  identityProvider: string;
};

export type AuthenticateProps = {
  AnonymousView: ComponentType<AnonymousViewProps>;
  AuthenticatedView: ComponentType<AuthenticatedViewProps>;
  PreparingView: ComponentType<PreparingViewProps>;
  AuthenticatingView: ComponentType<AuthenticatingViewProps>;
} & Partial<AuthOptions>;

type AuthState =
  | { type: "Preparing" }
  | { type: "Anonymous"; error?: string; login: () => void }
  | { type: "Authenticating" }
  | {
      type: "Authenticated";
      identity: Identity;
      logout: () => void;
    };

const NANOSECONDS_PER_DAY = BigInt(1000000000) * BigInt(3600) * BigInt(24);
const DEFAULT_TTL = BigInt(3) * NANOSECONDS_PER_DAY;
const DEFAULT_PROVIDER = "https://identity.ic0.app";

const initializeStateMachine = async (
  setState: (state: AuthState) => void,
  { maxTimeToLive, identityProvider }: AuthOptions
) => {
  const handleAuthSuccess = (client: AuthClient) => () =>
    setState({
      type: "Authenticated",
      identity: client.getIdentity(),
      logout: async () => {
        await client.logout();
        setAnonymous(client);
      },
    });

  const handleAuthError = (client: AuthClient) => (error?: string) =>
    setState({
      type: "Anonymous",
      error,
      login: doAuthenticate(client),
    });

  const doAuthenticate = (client: AuthClient) => () => {
    client.login({
      onSuccess: handleAuthSuccess(client),
      onError: handleAuthError(client),
      maxTimeToLive,
      identityProvider,
    });
    setState({ type: "Authenticating" });
  };

  const setAnonymous = (client: AuthClient) => {
    setState({
      type: "Anonymous",
      login: doAuthenticate(client),
    });
  };

  const client = await AuthClient.create();
  if (await client.isAuthenticated()) {
    handleAuthSuccess(client)();
  } else {
    setAnonymous(client);
  }
};

function useAuthState({ maxTimeToLive, identityProvider }: AuthOptions) {
  const [state, setState] = useState<AuthState>({ type: "Preparing" });

  useEffect(() => {
    initializeStateMachine(setState, {
      maxTimeToLive,
      identityProvider,
    });
  }, [maxTimeToLive, identityProvider]);

  return state;
}

export default function IIAuth({
  AnonymousView,
  AuthenticatedView,
  PreparingView,
  AuthenticatingView,
  maxTimeToLive = DEFAULT_TTL,
  identityProvider = DEFAULT_PROVIDER,
}: AuthenticateProps) {
  const state = useAuthState({ maxTimeToLive, identityProvider });

  switch (state.type) {
    case "Anonymous": {
      const { error, login } = state;
      return <AnonymousView error={error} login={login} />;
    }
    case "Authenticated": {
      const { identity, logout } = state;
      return <AuthenticatedView identity={identity} logout={logout} />;
    }
    case "Preparing": {
      return <PreparingView />;
    }
    case "Authenticating": {
      return <AuthenticatingView />;
    }
  }
}
