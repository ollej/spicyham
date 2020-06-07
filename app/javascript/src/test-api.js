class TestApi {
  constructor(elementId) {
    this.element = $(elementId);
  }

  setup() {
    this.element.click(this.test.bind(this));
    $("#user_api, #user_api_key, #user_api_user, #user_domain").change(this.reset.bind(this));
  }

  test() {
    this.processing();
    const data = {
      api: $("#user_api").val(),
      api_key: $("#user_api_key").val(),
      api_user: $("#user_api_user").val(),
      domain: $("#user_domain").val(),
    };
    $.post(this.element.attr("href"), data).done(this.success.bind(this)).fail(this.fail.bind(this));
    return false;
  }

  processing() {
    this.reset();
    $(".test-api-untested").addClass("d-none");
    $(".test-api-processing").removeClass("d-none");
  }

  success() {
    this.reset();
    $(".test-api-btn").removeClass("btn-outline-dark").addClass("btn-outline-success");
    $(".test-api-success").removeClass("d-none");
    $(".test-api-untested").addClass("d-none");
  }

  fail() {
    this.reset();
    $(".test-api-btn").removeClass("btn-outline-dark").addClass("btn-outline-danger");
    $(".test-api-failed").removeClass("d-none");
    $(".test-api-untested").addClass("d-none");
  }

  reset() {
    $(".test-api-btn").addClass("btn-outline-dark").removeClass("btn-outline-danger btn-outline-success");
    $(".test-api-icon").addClass("d-none");
    $(".test-api-untested").removeClass("d-none");
  }
}

if (typeof module !== "undefined") module.exports = TestApi;
