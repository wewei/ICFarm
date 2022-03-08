import { AuthenticatedViewProps } from "./IIAuth";

export default function Game({
  identity,
  logout,
}: AuthenticatedViewProps): JSX.Element {
  return (
    <div>
      TODO: the game view{" "}
      <a href="javascript:void(0)" onClick={logout}>
        logout
      </a>
    </div>
  );
}
