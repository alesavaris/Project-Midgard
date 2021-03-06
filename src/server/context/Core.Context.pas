unit Core.Context;

interface

uses
  Spring.Container;

type
  CoreContext = class sealed
    class procedure RegisterTypes(const container: TContainer); static;
  end;

implementation

uses
  Midgard.Critical.Section, Midgard.Critical.Section.Impl;

class procedure CoreContext.RegisterTypes(const container: TContainer);
begin
  container.RegisterType<IMidgardCriticalSection, TMidgardCriticalSection>.AsSingleton;

  container.Build;
end;

end.
