unit RESTFull.Container.Impl;

interface

uses
  System.Rtti,
  Spring,
  Spring.Services,
  Spring.Collections,
  Spring.Reflection,
  Spring.Container.Common,
  RESTFull.Controller,
  RESTFull.Container,
  MVCFramework,
  Midgard.Critical.Section;

type

  TRESTFullControllerItem = class(TInterfacedObject, IRESTFullControllerItem)
  strict private
    FControllerClass: TRESTFullControllerClass;
    FDelegate: TMVCControllerDelegate;
    function GetControllerClass: TRESTFullControllerClass;
    function GetDelegate: TMVCControllerDelegate;
  strict protected
    property ControllerClass: TRESTFullControllerClass read GetControllerClass;
    property Delegate: TMVCControllerDelegate read GetDelegate;
  public
    constructor Create(const controllerClass: TRESTFullControllerClass; const delegate: TMVCControllerDelegate);
  end;

  TRESTFullContainer = class(TInterfacedObject, IRESTFullContainer)
  strict private
    FControllers: IDictionary<string, IRESTFullControllerItem>;
    [Inject]
    FCriticalSection: ICriticalSection;
  strict protected
    function Controllers(): IDictionary<string, IRESTFullControllerItem>;
  public
    constructor Create;
  end;

implementation

{ TRESTFullContainer }

function TRESTFullContainer.Controllers: IDictionary<string, IRESTFullControllerItem>;
begin
  if (FControllers = nil) then
  begin
    FCriticalSection.Enter;
    try
      FControllers := TCollections.CreateDictionary<string, IRESTfullControllerItem>;
      TType.GetTypes.ForEach(
        procedure(const rttiType: TRttiType)
        begin
          if (rttiType.IsInstance) and (rttiType.HasCustomAttribute<MVCPathAttribute>) then
            FControllers.AddOrSetValue(rttiType.AsClass.MetaclassType.QualifiedClassName,
              TRESTFullControllerItem.Create(TRESTFullControllerClass(rttiType.AsClass.MetaclassType),
              function: TMVCController
              begin
                Result := ServiceLocator.GetService(rttiType.AsClass.Handle).AsType<TMVCController>;
              end
              ));
        end
        );
    finally
      FCriticalSection.Leave;
    end;
  end;
  Result := FControllers;
end;

constructor TRESTFullContainer.Create;
begin
  FControllers := nil;
end;

{ TRESTFullControllerItem }

constructor TRESTFullControllerItem.Create(const controllerClass: TRESTFullControllerClass; const delegate: TMVCControllerDelegate);
begin
  FControllerClass := controllerClass;
  FDelegate := delegate;
end;

function TRESTFullControllerItem.GetControllerClass: TRESTFullControllerClass;
begin
  Result := FControllerClass;
end;

function TRESTFullControllerItem.GetDelegate: TMVCControllerDelegate;
begin
  Result := FDelegate;
end;

end.
