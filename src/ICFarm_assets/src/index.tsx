import { ICFarm } from "../../declarations/ICFarm";
import { render } from "react-dom";
import IIAuth, { AnonymousViewProps } from "./component/IIAuth";
import Game from "./component/Game";

function AnonymousView({ login, error }: AnonymousViewProps): JSX.Element {
  return (
    <div>
      <button onClick={login}>Login</button>
      {error && <span>{error}</span>}
    </div>
  );
}

function PreparingView(): JSX.Element {
  return <div>Preparing...</div>;
}

function AuthenticatingView(): JSX.Element {
  return <div>Authenticating...</div>;
}

const identityProvider =
  process.env.NODE_ENV === "development"
    ? `http://${process.env.INTERNET_IDENTITY_CANISTER_ID}.localhost:8000`
    : `https://identity.ic0.app`;

render(
  <IIAuth
    AuthenticatedView={Game}
    AnonymousView={AnonymousView}
    PreparingView={PreparingView}
    AuthenticatingView={AuthenticatingView}
    identityProvider={identityProvider}
  />,
  document.getElementById("main")
);
