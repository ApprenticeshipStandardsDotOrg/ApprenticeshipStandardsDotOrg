import { __internal__ } from './index';

declare const ActivationGroup: typeof __internal__.ActivationGroup;
declare type ActivationGroup = __internal__.ActivationGroup;

declare const AnnotationAuthorityManager: typeof __internal__.AnnotationAuthorityManager;
declare type AnnotationAuthorityManager =
  __internal__.AnnotationAuthorityManager;

declare const AnnotationPermission: typeof __internal__.AnnotationPermission;
declare type AnnotationPermission = __internal__.AnnotationPermission;

declare const Disposable: typeof __internal__.Disposable;
declare type Disposable = __internal__.Disposable;

declare const DivScrollWrap: typeof __internal__.DivScrollWrap;
declare type DivScrollWrap = __internal__.DivScrollWrap;

declare const PDFViewer: typeof __internal__.PDFViewer;
declare type PDFViewer = __internal__.PDFViewer;

declare const SnapshotServer: typeof __internal__.SnapshotServer;
declare type SnapshotServer = __internal__.SnapshotServer;

declare const UserPermission: typeof __internal__.UserPermission;
declare type UserPermission = __internal__.UserPermission;

export declare type GetAnnotPermissionsCallback =
  __internal__.GetAnnotPermissionsCallback;

declare const CustomScrollWrap: typeof __internal__.CustomScrollWrap;
declare type CustomScrollWrap = __internal__.CustomScrollWrap;

declare namespace PDF {
  namespace coordinates {
    export import DevicePoint = __internal__.DevicePoint;

    export import DeviceRect = __internal__.DeviceRect;

    export import PDFPoint = __internal__.PDFPoint;

    export import PDFRect = __internal__.PDFRect;
  }

  namespace util {
    export import FontMap = __internal__.FontMap;

    export import Glyphs = __internal__.Glyphs;

    export import PageRange = __internal__.PageRange;

    export import Unit = __internal__.Unit;
  }

  namespace actions {
    export import Action = __internal__.Action;

    export import GoToAction = __internal__.GoToAction;

    export import HideAction = __internal__.HideAction;

    export import JavaScriptAction = __internal__.JavaScriptAction;

    export import ResetFormAction = __internal__.ResetFormAction;

    export import URIAction = __internal__.URIAction;
  }

  namespace annots {
    namespace constant {
      export import Annot_Flags = __internal__.Annot_Flags;

      export import Annot_Type = __internal__.Annot_Type;

      export import Annot_Unit_Type = __internal__.Annot_Unit_Type;

      export import MARKUP_ANNOTATION_STATE = __internal__.MARKUP_ANNOTATION_STATE;
    }

    namespace summaries {
      export import IAnnotationSummary = __internal__.IAnnotationSummary;

      export import ICaretAnnotationSummary = __internal__.ICaretAnnotationSummary;

      export import ICircleAnnotationSummary = __internal__.ICircleAnnotationSummary;

      export import IFileAttachmentAnnotationSummary = __internal__.IFileAttachmentAnnotationSummary;

      export import IFreeTextAnnotationSummary = __internal__.IFreeTextAnnotationSummary;

      export import IFreeTextCalloutAnnotationSummary = __internal__.IFreeTextCalloutAnnotationSummary;

      export import IFreeTextTextBoxAnnotationSummary = __internal__.IFreeTextTextBoxAnnotationSummary;

      export import IFreeTextTypewriterAnnotationSummary = __internal__.IFreeTextTypewriterAnnotationSummary;

      export import IHighlightAnnotationSummary = __internal__.IHighlightAnnotationSummary;

      export import IInkAnnotationSummary = __internal__.IInkAnnotationSummary;

      export import ILineAnnotationSummary = __internal__.ILineAnnotationSummary;

      export import ILinkAnnotationSummary = __internal__.ILinkAnnotationSummary;

      export import IMarkupAnnotationSummary = __internal__.IMarkupAnnotationSummary;

      export import INoteAnnotationSummary = __internal__.INoteAnnotationSummary;

      export import IPolygonAnnotationSummary = __internal__.IPolygonAnnotationSummary;

      export import IPolylineAnnotationSummary = __internal__.IPolylineAnnotationSummary;

      export import IPopupAnnotationSummary = __internal__.IPopupAnnotationSummary;

      export import IRedactAnnotationSummary = __internal__.IRedactAnnotationSummary;

      export import ISquareAnnotationSummary = __internal__.ISquareAnnotationSummary;

      export import ISquigglyAnnotationSummary = __internal__.ISquigglyAnnotationSummary;

      export import IStrikeoutAnnotationSummary = __internal__.IStrikeoutAnnotationSummary;

      export import ITextMarkupAnnotationSummary = __internal__.ITextMarkupAnnotationSummary;

      export import IUnderlineAnnotationSummary = __internal__.IUnderlineAnnotationSummary;
    }

    export import Annot = __internal__.Annot;

    export import AnnotFlag = __internal__.AnnotFlag;

    export import Caret = __internal__.Caret;

    export import Circle = __internal__.Circle;

    export import FileAttachment = __internal__.FileAttachment;

    export import FreeText = __internal__.FreeText;

    export import Highlight = __internal__.Highlight;

    export import Ink = __internal__.Ink;

    export import Line = __internal__.Line;

    export import Link = __internal__.Link;

    export import Markup = __internal__.Markup;

    export import Note = __internal__.Note;

    export import Polygon = __internal__.Polygon;

    export import PolyLine = __internal__.PolyLine;

    export import Redact = __internal__.Redact;

    export import Screen = __internal__.Screen;

    export import Sound = __internal__.Sound;

    export import Square = __internal__.Square;

    export import Squiggly = __internal__.Squiggly;

    export import Stamp = __internal__.Stamp;

    export import StrikeOut = __internal__.StrikeOut;

    export import TextMarkup = __internal__.TextMarkup;

    export import Underline = __internal__.Underline;

    export import Widget = __internal__.Widget;
  }

  namespace comparison {
    export import ComparePageRange = __internal__.ComparePageRange;

    export import LineThicknessValues = __internal__.LineThicknessValues;

    export import MarkingColorValues = __internal__.MarkingColorValues;

    export import OpacityValues = __internal__.OpacityValues;
  }

  namespace constant {
    export import Action_Trigger = __internal__.Action_Trigger;

    export import Action_Type = __internal__.Action_Type;

    export import Additional_Permission = __internal__.Additional_Permission;

    export import Alignment = __internal__.Alignment;

    export import AnnotUpdatedType = __internal__.AnnotUpdatedType;

    export import Border_Style = __internal__.Border_Style;

    export import Box_Type = __internal__.Box_Type;

    export import Calc_Margin_Mode = __internal__.Calc_Margin_Mode;

    export import Cipher_Type = __internal__.Cipher_Type;

    export import DataEvents = __internal__.DataEvents;

    export import date_Format = __internal__.date_Format;

    export import Ending_Style = __internal__.Ending_Style;

    export import Error_Code = __internal__.Error_Code;

    export import File_Type = __internal__.File_Type;

    export import FileAttachment_Icon = __internal__.FileAttachment_Icon;

    export import Flatten_Option = __internal__.Flatten_Option;

    export import Font_Charset = __internal__.Font_Charset;

    export import Font_CIDCharset = __internal__.Font_CIDCharset;

    export import Font_Descriptor_Flags = __internal__.Font_Descriptor_Flags;

    export import Font_StandardID = __internal__.Font_StandardID;

    export import Font_Style = __internal__.Font_Style;

    export import Font_Styles = __internal__.Font_Styles;

    export import Graphics_FillMode = __internal__.Graphics_FillMode;

    export import Graphics_ObjectType = __internal__.Graphics_ObjectType;

    export import Highlight_Mode = __internal__.Highlight_Mode;

    export import MK_Properties = __internal__.MK_Properties;

    export import Note_Icon = __internal__.Note_Icon;

    export import page_Number_Format = __internal__.page_Number_Format;

    export import Point_Type = __internal__.Point_Type;

    export import POS_TYPE = __internal__.POS_TYPE;

    export import Position = __internal__.Position;

    export import PosType = __internal__.PosType;

    export import Range_Filter = __internal__.Range_Filter;

    export import Relationship = __internal__.Relationship;

    export import Rendering_Content = __internal__.Rendering_Content;

    export import Rendering_Usage = __internal__.Rendering_Usage;

    export import Rotation = __internal__.Rotation;

    export import Rotation_Degree = __internal__.Rotation_Degree;

    export import Saving_Flag = __internal__.Saving_Flag;

    export import Search_Flag = __internal__.Search_Flag;

    export import Signature_Ap_Flags = __internal__.Signature_Ap_Flags;

    export import Signature_State = __internal__.Signature_State;

    export import Sound_Icon = __internal__.Sound_Icon;

    export import STAMP_TEXT_TYPE = __internal__.STAMP_TEXT_TYPE;

    export import Standard_Font = __internal__.Standard_Font;

    export import Text_Mode = __internal__.Text_Mode;

    export import User_Permissions = __internal__.User_Permissions;

    export import Watermark_Flag = __internal__.Watermark_Flag;

    export import ZoomMode = __internal__.ZoomMode;
  }

  namespace form {
    namespace constant {
      export import Field_Flag = __internal__.Field_Flag;

      export import Field_Type = __internal__.Field_Type;
    }

    export import PDFControl = __internal__.PDFControl;

    export import PDFField = __internal__.PDFField;

    export import PDFForm = __internal__.PDFForm;

    export import PDFSignature = __internal__.PDFSignature;
  }

  namespace search {
    export import DocTextSearch = __internal__.DocTextSearch;

    export import PageTextSearch = __internal__.PageTextSearch;

    export import TextSearchMatch = __internal__.TextSearchMatch;
  }

  namespace progress {
    export import TaskProgress = __internal__.TaskProgress;

    export import TaskProgressData = __internal__.TaskProgressData;
  }

  export import GraphicsObject = __internal__.GraphicsObject;

  export import HeaderFooter = __internal__.HeaderFooter;

  export import ILayerNode = __internal__.ILayerNode;

  export import ImageObject = __internal__.ImageObject;

  export import Matrix = __internal__.Matrix;

  export import PathObject = __internal__.PathObject;

  export import PDFBookmark = __internal__.PDFBookmark;

  export import PDFDictionary = __internal__.PDFDictionary;

  export import PDFDoc = __internal__.PDFDoc;

  export import PDFPage = __internal__.PDFPage;

  export import PDFPageBatchProcessor = __internal__.PDFPageBatchProcessor;

  export import TextObject = __internal__.TextObject;
}

declare namespace shared {
  export import Color = __internal__.Color;

  export import getRanges = __internal__.getRanges;

  export import getUnitByName = __internal__.getUnitByName;
}

declare namespace stamp {
  export import StampInfo = __internal__.StampInfo;

  export import StampService = __internal__.StampService;
}

declare namespace add_ons {
  namespace PDFViewCtrl_CreateAnnotAddonModule {
    export import CreateAnnotAddon = __internal__.CreateAnnotAddon;
  }
}

declare namespace collab {
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

declare namespace renderers {
  namespace annotsRender {
    export import AnnotRender = __internal__.AnnotRender;

    export import ViewerAnnotManager = __internal__.ViewerAnnotManager;
  }

  export import PDFDocRender = __internal__.PDFDocRender;

  export import PDFPageRender = __internal__.PDFPageRender;
}

declare namespace stateHandler {
  export import HandStateHandlerConfig = __internal__.HandStateHandlerConfig;

  export import IStateHandler = __internal__.IStateHandler;

  export import StampStateHandlerParams = __internal__.StampStateHandlerParams;

  export import StateHandlerManager = __internal__.StateHandlerManager;

  export import StateHandlerConfig = __internal__.StateHandlerConfig;
}

declare namespace pdfjs {
  export import ActionCallback = __internal__.ActionCallback;

  export import AlertOptions = __internal__.AlertOptions;
}

declare namespace overlayComparison {
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

declare namespace constants {
  export import ANNOTATION_PERMISSION = __internal__.ANNOTATION_PERMISSION;

  export import MouseEventObjectType = __internal__.MouseEventObjectType;

  export import OPEN_FILE_TYPE = __internal__.OPEN_FILE_TYPE;

  export import PagePointType = __internal__.PagePointType;

  export import SNAP_MODE = __internal__.SNAP_MODE;

  export import STATE_HANDLER_NAMES = __internal__.STATE_HANDLER_NAMES;

  export import ViewerEvents = __internal__.ViewerEvents;
}

declare namespace interfaces {
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

declare namespace annotCompontents {
  export import AnnotComponent = __internal__.AnnotComponent;

  export import MarkupAnnotComponent = __internal__.MarkupAnnotComponent;
}

declare namespace readAloud {
  export import AbstractPDFTextToSpeechSynthesis = __internal__.AbstractPDFTextToSpeechSynthesis;

  export import PDFTextToSpeechSynthesis = __internal__.PDFTextToSpeechSynthesis;

  export import PDFTextToSpeechSynthesisTemplate = __internal__.PDFTextToSpeechSynthesisTemplate;

  export import PDFTextToSpeechUtterance = __internal__.PDFTextToSpeechUtterance;

  export import ReadAloudOptions = __internal__.ReadAloudOptions;

  export import ReadAloudService = __internal__.ReadAloudService;

  export import ReadAloudTextInformation = __internal__.ReadAloudTextInformation;

  export import PDFTextToSpeechSynthesisStatus = __internal__.PDFTextToSpeechSynthesisStatus;
}

declare namespace creation {
  export import CreateAnnotationService = __internal__.CreateAnnotationService;

  export import CreateFreeTextCalloutService = __internal__.CreateFreeTextCalloutService;
}

declare namespace viewerui {
  export import IContextMenu = __internal__.IContextMenu;

  export import IFloatingTooltip = __internal__.IFloatingTooltip;

  export import IViewerUI = __internal__.IViewerUI;

  export import TinyViewerUI = __internal__.TinyViewerUI;
}

declare namespace viewMode {
  export import IViewMode = __internal__.IViewMode;

  export import ViewModeManager = __internal__.ViewModeManager;
}

declare namespace DeviceInfo {
  export import isDesktop = __internal__.isDesktop;

  export import isMobile = __internal__.isMobile;

  export import isTablet = __internal__.isTablet;
}

declare namespace Log {
  export import LoggerFactory = __internal__.LoggerFactory;

  export import Log_Levels = __internal__.Log_Levels;
}
