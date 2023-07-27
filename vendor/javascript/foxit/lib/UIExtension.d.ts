import { __internal__ } from './index';

export declare const Modular: typeof __internal__.Modular;
export declare type Modular = __internal__.Modular;

export declare const PDFUI: typeof __internal__.PDFUI;
export declare type PDFUI = __internal__.PDFUI;

export declare const SeniorComponentFactory: typeof __internal__.SeniorComponentFactory;
export declare type SeniorComponentFactory =
  __internal__.SeniorComponentFactory;

export declare const SnapshotInteraction: typeof __internal__.SnapshotInteraction;
export declare type SnapshotInteraction = __internal__.SnapshotInteraction;

export declare const UIXAddon: typeof __internal__.UIXAddon;
export declare type UIXAddon = __internal__.UIXAddon;

export declare const UIXModule: typeof __internal__.UIXModule;
export declare type UIXModule = __internal__.UIXModule;

export declare const XViewerUI: typeof __internal__.XViewerUI;
export declare type XViewerUI = __internal__.XViewerUI;

export declare type Snapshot = __internal__.Snapshot;

export declare const UIEvents: typeof __internal__.UIEvents;
export declare type UIEvents = __internal__.UIEvents;

export declare const modular: typeof __internal__.modular;

export declare namespace components {
  namespace widgets {
    export import ButtonComponent = __internal__.ButtonComponent;

    export import ContextMenuComponent = __internal__.ContextMenuComponent;

    export import ContextMenuItemComponent = __internal__.ContextMenuItemComponent;

    export import DropdownButtonComponent = __internal__.DropdownButtonComponent;

    export import DropdownComponent = __internal__.DropdownComponent;

    export import DropdownItemComponent = __internal__.DropdownItemComponent;

    export import FileSelectorComponent = __internal__.FileSelectorComponent;

    export import FormFieldComponent = __internal__.FormFieldComponent;

    export import FormGroupComponent = __internal__.FormGroupComponent;

    export import GroupComponent = __internal__.GroupComponent;

    export import GroupListComponent = __internal__.GroupListComponent;

    export import GTabComponent = __internal__.GTabComponent;

    export import InlineColorPickerComponent = __internal__.InlineColorPickerComponent;

    export import LayerComponent = __internal__.LayerComponent;

    export import LayerHeaderComponent = __internal__.LayerHeaderComponent;

    export import LayerToolbarComponent = __internal__.LayerToolbarComponent;

    export import LayerViewComponent = __internal__.LayerViewComponent;

    export import NumberComponent = __internal__.NumberComponent;

    export import OptionGroupComponent = __internal__.OptionGroupComponent;

    export import PaddleComponent = __internal__.PaddleComponent;

    export import SidebarComponent = __internal__.SidebarComponent;

    export import SlotComponent = __internal__.SlotComponent;

    export import TabItemComponent = __internal__.TabItemComponent;

    export import TabsComponent = __internal__.TabsComponent;

    export import TextComponent = __internal__.TextComponent;

    export import ToolbarComponent = __internal__.ToolbarComponent;

    export import TooltipLayerComponent = __internal__.TooltipLayerComponent;
  }

  namespace business {
    export import CommentCardComponent = __internal__.CommentCardComponent;

    export import CommentListCardComponent = __internal__.CommentListCardComponent;

    export import ReplyCardComponent = __internal__.ReplyCardComponent;
  }

  namespace options {
    export import ButtonComponentOptions = __internal__.ButtonComponentOptions;

    export import ComponentOptions = __internal__.ComponentOptions;

    export import DropdownComponentOptions = __internal__.DropdownComponentOptions;

    export import FormFieldComponentOptions = __internal__.FormFieldComponentOptions;

    export import FragmentComponentOptions = __internal__.FragmentComponentOptions;

    export import GroupComponentOptions = __internal__.GroupComponentOptions;

    export import LayerComponentOptions = __internal__.LayerComponentOptions;

    export import LayerHeaderComponentOptions = __internal__.LayerHeaderComponentOptions;

    export import NumberComponentOptions = __internal__.NumberComponentOptions;

    export import PreConfiguredComponent = __internal__.PreConfiguredComponent;

    export import SeniorComponentSuperclassOptions = __internal__.SeniorComponentSuperclassOptions;

    export import SidebarPanelComponentOptions = __internal__.SidebarPanelComponentOptions;

    export import TabItemComponentOptions = __internal__.TabItemComponentOptions;

    export import UIFragmentOptions = __internal__.UIFragmentOptions;
  }

  export import Component = __internal__.Component;

  export import ContainerComponent = __internal__.ContainerComponent;

  export import LoadingComponent = __internal__.LoadingComponent;
}

export declare namespace controllers {
  export import AddImageController = __internal__.AddImageController;

  export import AnnotOperationController = __internal__.AnnotOperationController;

  export import ApplyAllRedactController = __internal__.ApplyAllRedactController;

  export import ApplyRedactController = __internal__.ApplyRedactController;

  export import CancelCreatingMeasurementController = __internal__.CancelCreatingMeasurementController;

  export import CompleteCreatingMeasurementController = __internal__.CompleteCreatingMeasurementController;

  export import ContinuousFacingPageModeController = __internal__.ContinuousFacingPageModeController;

  export import ContinuousPageModeController = __internal__.ContinuousPageModeController;

  export import Controller = __internal__.Controller;

  export import CopyAnnotTextController = __internal__.CopyAnnotTextController;

  export import CreateAreaController = __internal__.CreateAreaController;

  export import CreateAreaHighlightController = __internal__.CreateAreaHighlightController;

  export import CreateArrowController = __internal__.CreateArrowController;

  export import CreateCalloutController = __internal__.CreateCalloutController;

  export import CreateCaretController = __internal__.CreateCaretController;

  export import CreateCircleAreaController = __internal__.CreateCircleAreaController;

  export import CreateCircleController = __internal__.CreateCircleController;

  export import CreateDistanceController = __internal__.CreateDistanceController;

  export import CreateFileAttachmentController = __internal__.CreateFileAttachmentController;

  export import CreateHighlightController = __internal__.CreateHighlightController;

  export import CreateImageController = __internal__.CreateImageController;

  export import CreateLineController = __internal__.CreateLineController;

  export import CreateLinkController = __internal__.CreateLinkController;

  export import CreatePencilController = __internal__.CreatePencilController;

  export import CreatePerimeterController = __internal__.CreatePerimeterController;

  export import CreatePolygonCloudController = __internal__.CreatePolygonCloudController;

  export import CreatePolygonController = __internal__.CreatePolygonController;

  export import CreatePolylineController = __internal__.CreatePolylineController;

  export import CreateReplaceController = __internal__.CreateReplaceController;

  export import CreateSquareController = __internal__.CreateSquareController;

  export import CreateSquigglyController = __internal__.CreateSquigglyController;

  export import CreateStrikeoutController = __internal__.CreateStrikeoutController;

  export import CreateTextboxController = __internal__.CreateTextboxController;

  export import CreateTextController = __internal__.CreateTextController;

  export import CreateTypewriterController = __internal__.CreateTypewriterController;

  export import CreateUnderlineController = __internal__.CreateUnderlineController;

  export import DeleteAnnotController = __internal__.DeleteAnnotController;

  export import DownloadFileController = __internal__.DownloadFileController;

  export import FacingPageModeController = __internal__.FacingPageModeController;

  export import GotoFirstPageController = __internal__.GotoFirstPageController;

  export import GotoLastPageController = __internal__.GotoLastPageController;

  export import GotoNextPageController = __internal__.GotoNextPageController;

  export import GotoPageController = __internal__.GotoPageController;

  export import GotoPrevPageController = __internal__.GotoPrevPageController;

  export import HandController = __internal__.HandController;

  export import LoupeController = __internal__.LoupeController;

  export import MarqueeToolController = __internal__.MarqueeToolController;

  export import MediaDownloadController = __internal__.MediaDownloadController;

  export import MediaPauseController = __internal__.MediaPauseController;

  export import MediaPlayController = __internal__.MediaPlayController;

  export import OpenLocalFileController = __internal__.OpenLocalFileController;

  export import OpenRemoteFileController = __internal__.OpenRemoteFileController;

  export import SelectTextAnnotationController = __internal__.SelectTextAnnotationController;

  export import ShowActionsController = __internal__.ShowActionsController;

  export import ShowAnnotFormPropertiesController = __internal__.ShowAnnotFormPropertiesController;

  export import ShowAnnotPropertiesController = __internal__.ShowAnnotPropertiesController;

  export import ShowAnnotReplyController = __internal__.ShowAnnotReplyController;

  export import ShowRedactPlaceDialogController = __internal__.ShowRedactPlaceDialogController;

  export import ShowSearchPanelController = __internal__.ShowSearchPanelController;

  export import SignPropertyController = __internal__.SignPropertyController;

  export import SinglePageModeController = __internal__.SinglePageModeController;

  export import StatefulController = __internal__.StatefulController;

  export import TotalPageTextController = __internal__.TotalPageTextController;

  export import ViewModeController = __internal__.ViewModeController;
}

export declare namespace UIConsts {
  export import COMPONENT_EVENTS = __internal__.COMPONENT_EVENTS;

  export import FRAGMENT_ACTION = __internal__.FRAGMENT_ACTION;

  export import Loading_Mode = __internal__.Loading_Mode;

  export import WEBPDF_VIEWER_COMPONENT_NAME = __internal__.WEBPDF_VIEWER_COMPONENT_NAME;
}

export declare namespace appearances {
  export import AdaptiveAppearance = __internal__.AdaptiveAppearance;

  export import Appearance = __internal__.Appearance;

  export import MobileAppearance = __internal__.MobileAppearance;

  export import RibbonAppearance = __internal__.RibbonAppearance;

  export import UIAppearance = __internal__.UIAppearance;

  export import adaptive = __internal__.AdaptiveAppearance;
  export import mobile = __internal__.MobileAppearance;
  export import ribbon = __internal__.RibbonAppearance;
}

export namespace PDFViewCtrl {
  namespace shared {
    export import Color = __internal__.Color;

    export import getRanges = __internal__.getRanges;

    export import getUnitByName = __internal__.getUnitByName;
  }

  namespace stamp {
    export import StampInfo = __internal__.StampInfo;

    export import StampService = __internal__.StampService;
  }

  namespace add_ons {
    namespace PDFViewCtrl_CreateAnnotAddonModule {
      export import CreateAnnotAddon = __internal__.CreateAnnotAddon;
    }
  }

  namespace collab {
    export import AddMarkedStateCollaborationData = __internal__.AddMarkedStateCollaborationData;

    export import AddMarkedStateOperationData = __internal__.AddMarkedStateOperationData;

    export import AddReplyCollaborationData = __internal__.AddReplyCollaborationData;

    export import AddReplyOperationData = __internal__.AddReplyOperationData;

    export import AddReviewStateCollaborationData = __internal__.AddReviewStateCollaborationData;

    export import AddReviewStateOperationData = __internal__.AddReviewStateOperationData;

    export import CollaborationCommunicator = __internal__.CollaborationCommunicator;

    export import CollaborationData = __internal__.CollaborationData;

    export import CollaborationDataHandler = __internal__.CollaborationDataHandler;

    export import CollaborationSessionInfo = __internal__.CollaborationSessionInfo;

    export import CreateAnnotationCollaborationData = __internal__.CreateAnnotationCollaborationData;

    export import CreateAnnotationOperationData = __internal__.CreateAnnotationOperationData;

    export import ImportAnnotationsFileCollaborationData = __internal__.ImportAnnotationsFileCollaborationData;

    export import ImportAnnotationsFileOperationData = __internal__.ImportAnnotationsFileOperationData;

    export import MoveAnnotsBetweenPageCollaborationData = __internal__.MoveAnnotsBetweenPageCollaborationData;

    export import MoveAnnotsBetweenPageOperationData = __internal__.MoveAnnotsBetweenPageOperationData;

    export import PPOInsertPageCollaborationData = __internal__.PPOInsertPageCollaborationData;

    export import PPOInsertPageOperationData = __internal__.PPOInsertPageOperationData;

    export import PPOMovePageCollaborationData = __internal__.PPOMovePageCollaborationData;

    export import PPOMovePageOperationData = __internal__.PPOMovePageOperationData;

    export import PPORemovePageCollaborationData = __internal__.PPORemovePageCollaborationData;

    export import PPORemovePageOperationData = __internal__.PPORemovePageOperationData;

    export import PPORemovePagesCollaborationData = __internal__.PPORemovePagesCollaborationData;

    export import PPORemovePagesOperationData = __internal__.PPORemovePagesOperationData;

    export import PPORotatePageCollaborationData = __internal__.PPORotatePageCollaborationData;

    export import PPORotatePageOperationData = __internal__.PPORotatePageOperationData;

    export import RemoveAnnotationCollaborationData = __internal__.RemoveAnnotationCollaborationData;

    export import RemoveAnnotationOperationData = __internal__.RemoveAnnotationOperationData;

    export import RemoveReplyCollaborationData = __internal__.RemoveReplyCollaborationData;

    export import RemoveReplyOperationData = __internal__.RemoveReplyOperationData;

    export import UpdateAnnotationCollaborationData = __internal__.UpdateAnnotationCollaborationData;

    export import UpdateAnnotationOperationData = __internal__.UpdateAnnotationOperationData;

    export import UpdateAnnotContentCollaborationData = __internal__.UpdateAnnotContentCollaborationData;

    export import UpdateAnnotContentOperationData = __internal__.UpdateAnnotContentOperationData;

    export import UserCustomizeCollaborationData = __internal__.UserCustomizeCollaborationData;

    export import WebSocketCommunicator = __internal__.WebSocketCommunicator;

    export import COLLABORATION_ACTION = __internal__.COLLABORATION_ACTION;
  }

  namespace renderers {
    namespace annotsRender {
      export import AnnotRender = __internal__.AnnotRender;

      export import ViewerAnnotManager = __internal__.ViewerAnnotManager;
    }

    export import PDFDocRender = __internal__.PDFDocRender;

    export import PDFPageRender = __internal__.PDFPageRender;
  }

  namespace stateHandler {
    export import HandStateHandlerConfig = __internal__.HandStateHandlerConfig;

    export import IStateHandler = __internal__.IStateHandler;

    export import StampStateHandlerParams = __internal__.StampStateHandlerParams;

    export import StateHandlerManager = __internal__.StateHandlerManager;

    export import StateHandlerConfig = __internal__.StateHandlerConfig;
  }

  namespace pdfjs {
    export import ActionCallback = __internal__.ActionCallback;

    export import AlertOptions = __internal__.AlertOptions;
  }

  namespace overlayComparison {
    export import BlendColorResolverOptions = __internal__.BlendColorResolverOptions;

    export import CombinePixelsOptions = __internal__.CombinePixelsOptions;

    export import ImageData = __internal__.ImageData;

    export import OverlayComparisonOptions = __internal__.OverlayComparisonOptions;

    export import OverlayComparisonOptionsService = __internal__.OverlayComparisonOptionsService;

    export import OverlayComparisonService = __internal__.OverlayComparisonService;

    export import OverlayComparisonTransformationOptions = __internal__.OverlayComparisonTransformationOptions;

    export import DiffColor = __internal__.DiffColor;

    export import BlendColorResolver = __internal__.BlendColorResolver;

    export import CombinePixelsOptionsKey = __internal__.CombinePixelsOptionsKey;

    export import OnOptionChangeCallback = __internal__.OnOptionChangeCallback;
  }

  namespace constants {
    export import ANNOTATION_PERMISSION = __internal__.ANNOTATION_PERMISSION;

    export import MouseEventObjectType = __internal__.MouseEventObjectType;

    export import OPEN_FILE_TYPE = __internal__.OPEN_FILE_TYPE;

    export import PagePointType = __internal__.PagePointType;

    export import SNAP_MODE = __internal__.SNAP_MODE;

    export import STATE_HANDLER_NAMES = __internal__.STATE_HANDLER_NAMES;

    export import ViewerEvents = __internal__.ViewerEvents;
  }

  namespace interfaces {
    export import Activatable = __internal__.Activatable;

    export import AnnotTooltip = __internal__.AnnotTooltip;

    export import OpenFileParameter = __internal__.OpenFileParameter;

    export import PDFDocRendering = __internal__.PDFDocRendering;

    export import PDFPageRendering = __internal__.PDFPageRendering;

    export import PDFViewerRendering = __internal__.PDFViewerRendering;

    export import PrintProgressBar = __internal__.PrintProgressBar;

    export import ScrollWrap = __internal__.ScrollWrap;

    export import TextSelectionTool = __internal__.TextSelectionTool;
  }

  namespace annotCompontents {
    export import AnnotComponent = __internal__.AnnotComponent;

    export import MarkupAnnotComponent = __internal__.MarkupAnnotComponent;
  }

  namespace readAloud {
    export import AbstractPDFTextToSpeechSynthesis = __internal__.AbstractPDFTextToSpeechSynthesis;

    export import PDFTextToSpeechSynthesis = __internal__.PDFTextToSpeechSynthesis;

    export import PDFTextToSpeechSynthesisTemplate = __internal__.PDFTextToSpeechSynthesisTemplate;

    export import PDFTextToSpeechUtterance = __internal__.PDFTextToSpeechUtterance;

    export import ReadAloudOptions = __internal__.ReadAloudOptions;

    export import ReadAloudService = __internal__.ReadAloudService;

    export import ReadAloudTextInformation = __internal__.ReadAloudTextInformation;

    export import PDFTextToSpeechSynthesisStatus = __internal__.PDFTextToSpeechSynthesisStatus;
  }

  namespace creation {
    export import CreateAnnotationService = __internal__.CreateAnnotationService;

    export import CreateFreeTextCalloutService = __internal__.CreateFreeTextCalloutService;
  }

  namespace viewerui {
    export import IContextMenu = __internal__.IContextMenu;

    export import IFloatingTooltip = __internal__.IFloatingTooltip;

    export import IViewerUI = __internal__.IViewerUI;

    export import TinyViewerUI = __internal__.TinyViewerUI;
  }

  namespace viewMode {
    export import IViewMode = __internal__.IViewMode;

    export import ViewModeManager = __internal__.ViewModeManager;
  }

  namespace DeviceInfo {
    export import isDesktop = __internal__.isDesktop;

    export import isMobile = __internal__.isMobile;

    export import isTablet = __internal__.isTablet;
  }

  namespace Log {
    export import LoggerFactory = __internal__.LoggerFactory;

    export import Log_Levels = __internal__.Log_Levels;
  }

  export import ActivationGroup = __internal__.ActivationGroup;

  export import AnnotationAuthorityManager = __internal__.AnnotationAuthorityManager;

  export import AnnotationPermission = __internal__.AnnotationPermission;

  export import Disposable = __internal__.Disposable;

  export import DivScrollWrap = __internal__.DivScrollWrap;

  export import PDFViewer = __internal__.PDFViewer;

  export import SnapshotServer = __internal__.SnapshotServer;

  export import UserPermission = __internal__.UserPermission;

  export import GetAnnotPermissionsCallback = __internal__.GetAnnotPermissionsCallback;

  export import CustomScrollWrap = __internal__.CustomScrollWrap;
}
